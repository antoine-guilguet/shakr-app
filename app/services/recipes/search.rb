# frozen_string_literal: true

module Recipes
  # Full-text search with optional trigram fallback on recipe name. Expects +relation+
  # to already enforce visibility (public / private / any).
  class Search
    FTS_CONFIG = "simple"
    SIMILARITY_THRESHOLD = 0.25

    INGREDIENT_JOIN_SQL = <<~SQL.squish.freeze
      LEFT JOIN (
        SELECT recipe_id, string_agg(ingredients.name, ' ') AS ingredient_text
        FROM recipe_ingredients
        INNER JOIN ingredients ON ingredients.id = recipe_ingredients.ingredient_id
        GROUP BY recipe_id
      ) ing_agg ON ing_agg.recipe_id = recipes.id
    SQL

    def self.call(relation:, query:)
      new(relation:, query:).call
    end

    def initialize(relation:, query:)
      @relation = relation
      @query = query.to_s.strip
    end

    def call
      return nil if @query.blank?

      # Scope by allowed ids so we can ORDER BY rank without DISTINCT-on-SELECT conflicts.
      scoped = Recipe.where(id: @relation.unscope(:order).select(:id))

      combined_sql = "(recipes.search_vector || to_tsvector('#{FTS_CONFIG}', coalesce(ing_agg.ingredient_text, '')))"

      recipe = scoped
        .joins(INGREDIENT_JOIN_SQL)
        .where(
          "#{combined_sql} @@ plainto_tsquery(?, ?)",
          FTS_CONFIG,
          @query
        )
        .order(rank_order_sql(combined_sql))
        .first

      return recipe if recipe

      trigram_fallback
    end

    private

    def rank_order_sql(combined_sql)
      # Use sanitize_sql_array so Brakeman can see the user input is quoted.
      sql = Recipe.sanitize_sql_array(
        [
          "ts_rank_cd(#{combined_sql}, plainto_tsquery(?, ?)) DESC, recipes.updated_at DESC",
          FTS_CONFIG,
          @query
        ]
      )
      Arel.sql(sql)
    end

    def trigram_fallback
      scoped = Recipe.where(id: @relation.unscope(:order).select(:id))

      where_sql = Recipe.sanitize_sql_array(
        [ "similarity(lower(recipes.name::text), lower(?)) > ?", @query, SIMILARITY_THRESHOLD ]
      )
      order_sql = Recipe.sanitize_sql_array(
        [ "similarity(lower(recipes.name::text), lower(?)) DESC, recipes.updated_at DESC", @query ]
      )

      scoped
        .joins(INGREDIENT_JOIN_SQL)
        .where(where_sql)
        .order(Arel.sql(order_sql))
        .first
    end
  end
end
