require "test_helper"

class RecipeIngredientTest < ActiveSupport::TestCase
  test "rejects invalid unit" do
    ri = RecipeIngredient.new(
      recipe: recipes(:one),
      ingredient: ingredients(:gin),
      amount: 1,
      unit: "gallon",
      position: 99
    )
    assert_not ri.valid?
    assert_includes ri.errors[:unit], "is not included in the list"
  end
end
