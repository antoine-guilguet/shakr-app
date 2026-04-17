# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_03_25_181751) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "ingredients", force: :cascade do |t|
    t.string "name", null: false
    t.integer "kind", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower(TRIM(BOTH FROM name))", name: "index_ingredients_on_lower_trim_name", unique: true
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "ingredient_id", null: false
    t.decimal "amount", precision: 12, scale: 4
    t.string "unit", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
    t.index ["recipe_id", "position"], name: "index_recipe_ingredients_on_recipe_id_and_position", unique: true
    t.index ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "description"
    t.text "tags"
    t.text "steps"
    t.string "glassware"
    t.string "garnish"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "ingredients"
    t.boolean "is_public", default: false, null: false
    t.virtual "search_vector", type: :tsvector, as: "(((((setweight(to_tsvector('simple'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('simple'::regconfig, COALESCE(tags, ''::text)), 'B'::\"char\")) || setweight(to_tsvector('simple'::regconfig, COALESCE(description, ''::text)), 'C'::\"char\")) || setweight(to_tsvector('simple'::regconfig, COALESCE(steps, ''::text)), 'C'::\"char\")) || setweight(to_tsvector('simple'::regconfig, (COALESCE(glassware, ''::character varying))::text), 'C'::\"char\")) || setweight(to_tsvector('simple'::regconfig, (COALESCE(garnish, ''::character varying))::text), 'C'::\"char\"))", stored: true
    t.index "lower((name)::text) gin_trgm_ops", name: "index_recipes_on_lower_name_trgm", using: :gin
    t.index ["is_public"], name: "index_recipes_on_is_public"
    t.index ["search_vector"], name: "index_recipes_on_search_vector", using: :gin
    t.index ["user_id"], name: "index_recipes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "recipe_ingredients", "ingredients"
  add_foreign_key "recipe_ingredients", "recipes"
  add_foreign_key "recipes", "users"
end
