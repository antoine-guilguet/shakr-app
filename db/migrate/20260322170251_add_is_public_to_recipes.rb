class AddIsPublicToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :is_public, :boolean, default: false, null: false
    add_index :recipes, :is_public
  end
end
