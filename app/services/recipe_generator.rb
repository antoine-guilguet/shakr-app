require "net/http"
require "json"

class RecipeGenerator
  class Error < StandardError; end

  API_BASE = Rails.configuration.x.openai&.api_base || "https://api.openai.com/v1"
  DEFAULT_MODEL = Rails.configuration.x.openai&.model || ENV.fetch("OPENAI_MODEL", "gpt-4.1-mini")
  OPENAI_API_URL = "#{API_BASE}/chat/completions"

  ALLOWED_UNITS = %w[ml cl oz dash piece tsp].freeze

  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are an expert cocktail bartender and recipe developer.
    The user will describe what they are in the mood for, their constraints, and preferences.

    Respond with a single JSON object with this exact shape (TypeScript):
    type Recipe = {
      name: string;
      description?: string;
      tags: string[];
      ingredients: {
        name: string;
        quantity: number;
        unit: "ml" | "cl" | "oz" | "dash" | "piece" | "tsp";
      }[];
      steps: string[];
      glassware?: string;
      garnish?: string;
    };

    IMPORTANT RULES:
    - Your entire response MUST be valid JSON.
    - Do NOT wrap JSON in backticks or any other formatting.
    - Do NOT include comments in the JSON.
    - Always return a single top-level object with a `recipe` key whose value is a Recipe.
    - Use only these units for ingredients: "ml", "cl", "oz", "dash", "piece", "tsp".
    - Prefer metric units ("ml" or "cl") unless the user explicitly asks for something else.
    - Provide 3–8 ingredients and 3–8 steps.
    - Tags should be short descriptors like "sour", "citrus", "gin", "tropical".
  PROMPT

  def self.call(prompt:, user:)
    new(prompt:, user:).call
  end

  def initialize(prompt:, user:)
    @prompt = prompt.to_s.strip
    @user = user
  end

  def call
    raise Error, "Please describe what you're in the mood for." if @prompt.blank?

    response_body = perform_request
    payload = parse_response(response_body)
    attributes = normalize_recipe(payload)
    persist_recipe(attributes)
  rescue Error
    raise
  rescue StandardError => e
    Rails.logger.error(
      "[RecipeGenerator] Unexpected error: #{e.class} - #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
    )
    raise Error, "Sorry, something went wrong while generating your recipe."
  end

  private

  def perform_request
    uri = URI(OPENAI_API_URL)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.read_timeout = 25
    http.open_timeout = 5

    request = Net::HTTP::Post.new(
      uri,
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{openai_api_key}"
    )

    request.body = {
      model: DEFAULT_MODEL,
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        {
          role: "user",
          content: build_user_content
        }
      ]
    }.to_json

    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = http.request(request)
    duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round

    Rails.logger.info(
      "[RecipeGenerator] OpenAI request completed status=#{response.code} duration_ms=#{duration_ms}"
    )

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error(
        "[RecipeGenerator] OpenAI error status=#{response.code} body=#{response.body&.slice(0, 500)}"
      )
      raise Error, "The AI service is unavailable right now. Please try again in a moment."
    end

    response.body
  end

  def openai_api_key
    key = ENV["OPENAI_API_KEY"]
    return key if key.present?

    Rails.logger.error("[RecipeGenerator] OPENAI_API_KEY is not set")
    raise Error, "AI is not configured yet. Please contact support."
  end

  def build_user_content
    base = +"Create a cocktail recipe based on this request:\n\n"
    base << @prompt
    if @user&.respond_to?(:first_name) && @user.first_name.present?
      base << "\n\nThe recipe is for a person named #{@user.first_name}."
    end
    base
  end

  def parse_response(response_body)
    parsed = JSON.parse(response_body)
    content = parsed.dig("choices", 0, "message", "content")

    unless content
      Rails.logger.error("[RecipeGenerator] Missing message content in response: #{response_body.slice(0, 500)}")
      raise Error, "The AI response was incomplete. Please try again."
    end

    JSON.parse(content)
  rescue JSON::ParserError => e
    Rails.logger.error(
      "[RecipeGenerator] JSON parsing error: #{e.message} body=#{response_body.slice(0, 500)}"
    )
    raise Error, "The AI returned an invalid response. Please try again."
  end

  def normalize_recipe(payload)
    recipe = payload["recipe"] || payload
    raise Error, "The AI did not return a recipe." unless recipe.is_a?(Hash)

    ingredients = Array(recipe["ingredients"]).filter_map do |ingredient|
      next unless ingredient.is_a?(Hash)

      name = ingredient["name"].to_s.strip
      quantity = ingredient["quantity"].to_f
      unit = ingredient["unit"].to_s.strip

      next if name.blank? || quantity <= 0

      unit = unit.downcase
      unit = "ml" unless ALLOWED_UNITS.include?(unit)

      {
        name:,
        quantity:,
        unit:
      }
    end

    {
      name: recipe["name"].to_s.presence || "Untitled Cocktail",
      description: recipe["description"].to_s.presence,
      tags: Array(recipe["tags"]).map { |t| t.to_s.strip }.reject(&:blank?),
      ingredients:,
      steps: Array(recipe["steps"]).map { |s| s.to_s.strip }.reject(&:blank?),
      glassware: recipe["glassware"].to_s.presence,
      garnish: recipe["garnish"].to_s.presence
    }
  end

  def persist_recipe(attributes)
    Recipe.transaction do
      recipe = Recipe.create!(
        user: @user,
        name: attributes[:name],
        description: attributes[:description],
        tags: attributes[:tags],
        steps: attributes[:steps],
        glassware: attributes[:glassware],
        garnish: attributes[:garnish]
      )

      Array(attributes[:ingredients]).each_with_index do |ing, index|
        ingredient = Ingredient.find_or_create_by_name!(ing[:name], kind: :mixer)
        recipe.recipe_ingredients.create!(
          ingredient: ingredient,
          amount: BigDecimal(ing[:quantity].to_s),
          unit: ing[:unit],
          position: index
        )
      end

      recipe
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(
      "[RecipeGenerator] Failed to persist recipe: #{e.record.errors.full_messages.join(", ")}"
    )
    attributes
  end
end
