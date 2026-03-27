module Tools
  class SaveRecipeTool < BaseTool
    def name = "save_recipe"

    def description
      "Save the final recipe to the user's collection in the database."
    end

    def parameters_schema
      {
        type: "object",
        additionalProperties: false,
        properties: {
          name: {
            type: "string",
            description: "Recipe name."
          },
          description: {
            type: "string",
            description: "Optional recipe description."
          },
          tags: {
            type: "array",
            items: { type: "string" },
            description: "Optional short descriptors."
          },
          ingredients: {
            type: "array",
            description: "List of ingredients for the recipe.",
            items: {
              type: "object",
              additionalProperties: false,
              properties: {
                name: { type: "string" },
                quantity: { type: "number" },
                unit: { type: "string", enum: RecipeIngredient::UNITS }
              },
              required: ["name", "quantity", "unit"]
            }
          },
          steps: {
            type: "array",
            items: { type: "string" },
            description: "Ordered preparation steps."
          },
          glassware: {
            type: "string",
            description: "Optional serving glassware."
          },
          garnish: {
            type: "string",
            description: "Optional garnish."
          },
          is_public: {
            type: "boolean",
            description: "Whether this recipe should be public."
          }
        },
        required: ["name", "ingredients", "steps"]
      }
    end

    def call(user:, input:)
      recipe = Recipes::CreateFromAgent.call(user: user, input: input)

      {
        ok: true,
        recipe: {
          id: recipe.id,
          name: recipe.name,
          is_public: recipe.is_public?,
          url: Rails.application.routes.url_helpers.recipe_path(recipe)
        }
      }
    rescue Recipes::CreateFromAgent::ValidationError => e
      {
        ok: false,
        error: e.message,
        details: e.details
      }
    end
  end
end
