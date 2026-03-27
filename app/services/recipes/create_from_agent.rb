module Recipes
  class CreateFromAgent
    class ValidationError < StandardError
      attr_reader :details

      def initialize(message, details: [])
        super(message)
        @details = Array(details)
      end
    end

    def self.call(user:, input:)
      new(user:, input:).call
    end

    def initialize(user:, input:)
      @user = user
      @input = input.to_h
    end

    def call
      attributes = normalize_attributes

      recipe = nil
      Recipe.transaction do
        recipe = Recipe.new(
          user: @user,
          name: attributes[:name],
          description: attributes[:description],
          tags: attributes[:tags],
          steps: attributes[:steps],
          glassware: attributes[:glassware],
          garnish: attributes[:garnish],
          is_public: attributes[:is_public]
        )

        attributes[:ingredients].each_with_index do |ingredient_attrs, index|
          ingredient = Ingredient.find_or_create_by_name!(ingredient_attrs[:name], kind: :mixer)
          recipe.recipe_ingredients.build(
            ingredient: ingredient,
            amount: ingredient_attrs[:quantity],
            unit: ingredient_attrs[:unit],
            position: index
          )
        end

        recipe.save!
      end

      recipe
    rescue ActiveRecord::RecordInvalid => e
      details = e.record.errors.full_messages
      raise ValidationError.new("Recipe could not be saved.", details: details)
    end

    private

    def normalize_attributes
      name = @input["name"].to_s.strip
      raise ValidationError.new("name is required") if name.blank?

      steps = normalize_steps(@input["steps"])
      ingredients = normalize_ingredients(@input["ingredients"])

      {
        name: name,
        description: @input["description"].to_s.strip.presence,
        tags: normalize_tags(@input["tags"]),
        steps: steps,
        glassware: @input["glassware"].to_s.strip.presence,
        garnish: @input["garnish"].to_s.strip.presence,
        is_public: normalize_is_public(@input["is_public"]),
        ingredients: ingredients
      }
    end

    def normalize_tags(value)
      if value.is_a?(String)
        value.split(",")
      else
        Array(value)
      end.map { |tag| tag.to_s.strip }.reject(&:blank?)
    end

    def normalize_steps(value)
      steps = if value.is_a?(String)
        value.lines
      else
        Array(value)
      end.map { |step| step.to_s.strip }.reject(&:blank?)

      raise ValidationError.new("steps must contain at least one item") if steps.empty?

      steps
    end

    def normalize_ingredients(value)
      rows = Array(value)
      raise ValidationError.new("ingredients must contain at least one item") if rows.empty?

      rows.each_with_index.map do |row, index|
        entry = row.is_a?(Hash) ? row : {}
        name = entry["name"].to_s.strip
        quantity = entry["quantity"].to_f
        unit = entry["unit"].to_s.strip.downcase

        raise ValidationError.new("ingredients[#{index}].name is required") if name.blank?
        raise ValidationError.new("ingredients[#{index}].quantity must be > 0") if quantity <= 0
        unless RecipeIngredient::UNITS.include?(unit)
          raise ValidationError.new("ingredients[#{index}].unit must be one of: #{RecipeIngredient::UNITS.join(', ')}")
        end

        { name: name, quantity: quantity, unit: unit }
      end
    end

    def normalize_is_public(value)
      return false if value.nil?

      ActiveModel::Type::Boolean.new.cast(value)
    end
  end
end
