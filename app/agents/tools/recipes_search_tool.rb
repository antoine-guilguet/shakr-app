module Tools
  class RecipesSearchTool < BaseTool
      def name = "recipes_search"

      def description
        "Search the Shakr recipes database and return one best matching recipe the user is allowed to see."
      end

      def parameters_schema
        {
          type: "object",
          additionalProperties: false,
          properties: {
            query: {
              type: "string",
              description: "What the user is looking for, e.g. 'margarita', 'negroni', 'tropical rum'."
            },
            visibility: {
              type: "string",
              enum: %w[any public private],
              description: "Optional filter. 'private' means the user's own recipes. 'public' means community recipes."
            }
          },
          required: ["query"]
        }
      end

      def call(user:, input:)
        query = input.fetch("query", "").to_s.strip
        raise Error, "query is required" if query.blank?

        visibility = parse_visibility(input["visibility"])
        relation = base_relation_for(user:, visibility:)

        normalized = Recipes::QueryNormalizer.call(query)
        return { found: false } if normalized.blank?

        recipe = Recipes::Search.call(relation:, query: normalized)

        return { found: false } unless recipe

        recipe = Recipe.includes(recipe_ingredients: :ingredient).find(recipe.id)

        {
          found: true,
          recipe: {
            id: recipe.id,
            name: recipe.name,
            is_public: recipe.is_public?,
            description: recipe.description.to_s,
            tags: Array(recipe.tags),
            url: Rails.application.routes.url_helpers.recipe_path(recipe),
            ingredients: ingredient_lines_for(recipe),
            steps_preview: Array(recipe.steps).map(&:to_s).map(&:strip).reject(&:blank?)
          }
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

      def base_relation_for(user:, visibility:)
        case visibility
        when "public"
          Recipe.where(is_public: true)
        when "private"
          Recipe.where(user_id: user.id)
        else
          Recipe.where(is_public: true).or(Recipe.where(user_id: user.id)).distinct
        end
      end
  end
end

