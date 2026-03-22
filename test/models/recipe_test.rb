require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "creates recipe with ingredient from catalog via nested attributes" do
    recipe = Recipe.new(
      name: "Gin highball",
      user: users(:one),
      tags: [],
      steps: ["stir"],
      recipe_ingredients_attributes: {
        "0" => {
          ingredient_id: ingredients(:gin).id,
          amount: "1",
          unit: "oz"
        }
      }
    )

    assert recipe.save
    assert_equal 1, recipe.recipe_ingredients.count
    assert_equal ingredients(:gin).id, recipe.recipe_ingredients.first.ingredient_id
  end

  test "fixture recipe has ordered recipe ingredients" do
    r = recipes(:one)
    names = r.recipe_ingredients.map { |line| line.ingredient.name }
    assert_equal ["Gin", "Lemon juice"], names
  end
end
