class CreateIngredientsAndRecipeIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredients do |t|
      t.string :name, null: false
      t.integer :kind, null: false, default: 1

      t.timestamps
    end

    add_index :ingredients, "lower(trim(name))", unique: true, name: "index_ingredients_on_lower_trim_name"

    create_table :recipe_ingredients do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 4
      t.string :unit, null: false
      t.integer :position, null: false

      t.timestamps
    end

    add_index :recipe_ingredients, [:recipe_id, :position], unique: true
  end
end
