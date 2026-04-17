# frozen_string_literal: true

require "test_helper"

class Recipes::CreateFromAgentTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "creates recipe with ordered recipe ingredients" do
    payload = {
      "name" => "Agent Gimlet",
      "description" => "Bright and tart.",
      "tags" => [ "gin", "citrus" ],
      "steps" => [ "Shake with ice.", "Fine strain into a coupe." ],
      "ingredients" => [
        { "name" => "Gin", "quantity" => 50, "unit" => "ml" },
        { "name" => "Lime juice", "quantity" => 25, "unit" => "ml" }
      ],
      "glassware" => "Coupe",
      "garnish" => "Lime zest",
      "is_public" => true
    }

    recipe = nil
    assert_difference -> { Recipe.count }, 1 do
      assert_difference -> { RecipeIngredient.count }, 2 do
        recipe = Recipes::CreateFromAgent.call(user: @user, input: payload)
      end
    end

    assert_equal "Agent Gimlet", recipe.name
    assert_equal true, recipe.is_public?
    assert_equal [ "gin", "citrus" ], recipe.tags
    assert_equal [ 0, 1 ], recipe.recipe_ingredients.order(:position).pluck(:position)
  end

  test "rejects invalid ingredient unit" do
    payload = {
      "name" => "Bad Unit",
      "steps" => [ "Build" ],
      "ingredients" => [
        { "name" => "Gin", "quantity" => 45, "unit" => "liter" }
      ]
    }

    assert_no_difference -> { Recipe.count } do
      error = assert_raises(Recipes::CreateFromAgent::ValidationError) do
        Recipes::CreateFromAgent.call(user: @user, input: payload)
      end
      assert_match(/unit must be one of/i, error.message)
    end
  end

  test "defaults visibility to private when missing" do
    payload = {
      "name" => "Private Default",
      "steps" => [ "Stir" ],
      "ingredients" => [
        { "name" => "Gin", "quantity" => 45, "unit" => "ml" }
      ]
    }

    recipe = Recipes::CreateFromAgent.call(user: @user, input: payload)
    assert_equal false, recipe.is_public?
  end
end
