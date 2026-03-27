module Tools
  class UiStateUpdateTool < BaseTool
    def name = "ui_state_update"

    def description
      "Update the voice UI state with summary, suggested actions, and optional recipe suggestion."
    end

    def parameters_schema
      {
        type: "object",
        additionalProperties: false,
        properties: {
          summary: {
            type: "string",
            description: "Short sentence describing what the assistant understood."
          },
          phase: {
            type: "string",
            enum: %w[listening clarifying suggesting_recipe confirming_save done],
            description: "Optional conversation phase."
          },
          actions: {
            type: "array",
            description: "Suggested next actions rendered as quick buttons.",
            items: {
              type: "object",
              additionalProperties: false,
              properties: {
                id: { type: "string" },
                label: { type: "string" },
                utterance: { type: "string" }
              },
              required: ["id", "label", "utterance"]
            }
          },
          recipe: {
            type: %w[object null],
            description: "Optional recipe suggestion for the dedicated recipe panel.",
            additionalProperties: false,
            properties: {
              name: { type: "string" },
              description: { type: "string" },
              badge: { type: "string" },
              url: { type: "string" },
              ingredients: {
                type: "array",
                items: { type: "string" }
              },
              steps_preview: {
                type: "array",
                items: { type: "string" }
              }
            },
            required: ["name"]
          }
        }
      }
    end

    def call(user:, input:)
      summary = input["summary"]
      phase = input["phase"]
      actions = input["actions"]
      recipe = input["recipe"]

      if summary.blank? && phase.blank? && actions.blank? && !input.key?("recipe")
        raise Error, "At least one of summary, phase, actions, or recipe is required."
      end

      {
        ok: true,
        summary: summary.to_s.strip.presence,
        phase: phase.to_s.strip.presence,
        actions: normalize_actions(actions),
        recipe: normalize_recipe(recipe)
      }
    end

    private

    def normalize_actions(actions)
      return [] unless actions.is_a?(Array)

      actions.filter_map do |action|
        next unless action.is_a?(Hash)

        id = action["id"].to_s.strip
        label = action["label"].to_s.strip
        utterance = action["utterance"].to_s.strip
        next if id.blank? || label.blank? || utterance.blank?

        { id:, label:, utterance: }
      end
    end

    def normalize_recipe(recipe)
      return nil if recipe.nil?
      return nil unless recipe.is_a?(Hash)

      name = recipe["name"].to_s.strip
      return nil if name.blank?

      {
        name:,
        description: recipe["description"].to_s,
        badge: recipe["badge"].to_s.presence,
        url: recipe["url"].to_s.presence,
        ingredients: normalize_ingredients(recipe["ingredients"]),
        steps_preview: Array(recipe["steps_preview"]).map(&:to_s).map(&:strip).reject(&:blank?)
      }
    end

    def normalize_ingredients(ingredients)
      Array(ingredients).filter_map do |item|
        if item.is_a?(Hash)
          name = item["name"].to_s.strip.presence || item[:name].to_s.strip.presence
          quantity = item["quantity"].presence || item[:quantity].presence
          unit = item["unit"].to_s.strip.presence || item[:unit].to_s.strip.presence

          next if name.blank?

          parts = [quantity, unit, name].compact.map(&:to_s).map(&:strip).reject(&:blank?)
          next parts.join(" ") if parts.any?
        end

        text = item.to_s.strip
        text.presence
      end
    end
  end
end
