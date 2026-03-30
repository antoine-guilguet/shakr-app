module Tools
  class UpdateRecipeTool < BaseTool
    def name = "update_recipe"

    def description
      "Update an existing recipe the user can see. If the recipe belongs to the user, it is updated in place. " \
        "If it is a public recipe owned by someone else, a new private copy is created in the user's collection. " \
        "Always send complete ingredients and steps arrays (same shape as save_recipe). " \
        "Use recipe_id from a recent recipes_search result, or call recipes_search again first."
    end

    def parameters_schema
      {
        type: "object",
        additionalProperties: false,
        properties: {
          recipe_id: {
            type: "integer",
            description: "Database id of the recipe to update (from recipes_search)."
          },
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
            description: "Full list of ingredients for the recipe.",
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
            description: "Whether this recipe should be public (only applies when updating your own recipe; " \
              "forked copies default to private unless you set this to true)."
          }
        },
        required: ["recipe_id", "name", "ingredients", "steps"]
      }
    end

    def call(user:, input:)
      result = Recipes::UpdateOrForkFromAgent.call(user: user, input: input)
      recipe = Recipe.includes(recipe_ingredients: :ingredient).find(result.recipe.id)

      {
        ok: true,
        forked: result.forked,
        recipe: {
          id: recipe.id,
          name: recipe.name,
          is_public: recipe.is_public?,
          description: recipe.description.to_s,
          url: Rails.application.routes.url_helpers.recipe_path(recipe),
          ingredients: ingredient_lines_for(recipe),
          steps_preview: Array(recipe.steps).map(&:to_s).map(&:strip).reject(&:blank?)
        }
      }
    rescue Recipes::CreateFromAgent::ValidationError => e
      {
        ok: false,
        error: e.message,
        details: e.details
      }
    end

    private

    def ingredient_lines_for(recipe)
      recipe.recipe_ingredients.map do |ri|
        name = ri.ingredient&.name.to_s.strip
        next if name.blank?

        qty = ri.amount
        qty_str =
          if qty.nil?
            ""
          else
            qty.to_s.sub(/\.0+\z/, "").sub(/\.\z/, "")
          end

        unit = ri.unit.to_s.strip
        [qty_str, unit, name].map(&:to_s).reject(&:blank?).join(" ").strip
      end.compact
    end
  end
end
