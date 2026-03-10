class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.text :tags
      t.text :ingredients
      t.text :steps
      t.string :glassware
      t.string :garnish

      t.timestamps
    end
  end
end
