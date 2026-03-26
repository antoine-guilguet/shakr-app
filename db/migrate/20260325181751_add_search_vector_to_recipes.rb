# frozen_string_literal: true

class AddSearchVectorToRecipes < ActiveRecord::Migration[8.0]
  def up
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    execute <<~SQL.squish
      ALTER TABLE recipes ADD COLUMN search_vector tsvector
      GENERATED ALWAYS AS (
        setweight(to_tsvector('simple', coalesce(recipes.name, '')), 'A') ||
        setweight(to_tsvector('simple', coalesce(recipes.tags::text, '')), 'B') ||
        setweight(to_tsvector('simple', coalesce(recipes.description, '')), 'C') ||
        setweight(to_tsvector('simple', coalesce(recipes.steps::text, '')), 'C') ||
        setweight(to_tsvector('simple', coalesce(recipes.glassware, '')), 'C') ||
        setweight(to_tsvector('simple', coalesce(recipes.garnish, '')), 'C')
      ) STORED;
    SQL

    add_index :recipes, :search_vector, using: :gin
    execute <<~SQL.squish
      CREATE INDEX index_recipes_on_lower_name_trgm ON recipes USING gin (lower(name::text) gin_trgm_ops);
    SQL
  end

  def down
    execute "DROP INDEX IF EXISTS index_recipes_on_lower_name_trgm;"
    remove_index :recipes, :search_vector
    remove_column :recipes, :search_vector
  end
end
