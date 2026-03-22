require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  test "find_or_create_by_name! is case-insensitive" do
    # fixtures include "Gin" as spirit
    ing = Ingredient.find_or_create_by_name!("  GIN ", kind: :liqueur)
    assert_equal "Gin", ing.name
    assert_equal "spirit", ing.kind
  end

  test "find_or_create_by_name! raises on blank name" do
    assert_raises(ArgumentError) { Ingredient.find_or_create_by_name!("  ") }
  end
end
