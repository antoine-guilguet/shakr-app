module Tools
  class CreateAiRecipeTool < BaseTool
    def name = "create_ai_recipe"

    def description
      "Generate a draft cocktail recipe based on the user's requirements (does not save to DB)."
    end

    def parameters_schema
      {
        type: "object",
        additionalProperties: false,
        properties: {
          prompt: {
            type: "string",
            description: "User requirements and constraints for the recipe (flavors, spirit, sweetness, allergens, available ingredients, etc.)."
          }
        },
        required: [ "prompt" ]
      }
    end

    def call(user:, input:)
      prompt = input.fetch("prompt", "").to_s.strip
      raise Error, "prompt is required" if prompt.blank?

      attributes = RecipeGenerator.call(prompt:, user:)

      {
        ok: true,
        recipe: {
          name: attributes[:name].to_s,
          description: attributes[:description].to_s,
          tags: Array(attributes[:tags]),
          ingredients: Array(attributes[:ingredients]).map do |ing|
            {
              name: ing[:name].to_s,
              quantity: ing[:quantity].to_f,
              unit: ing[:unit].to_s
            }
          end,
          steps: Array(attributes[:steps]).map(&:to_s),
          glassware: attributes[:glassware].to_s,
          garnish: attributes[:garnish].to_s
        }
      }
    rescue RecipeGenerator::Error => e
      { ok: false, error: e.message }
    end
  end
end
