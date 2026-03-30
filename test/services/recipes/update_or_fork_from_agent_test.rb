# frozen_string_literal: true

require "test_helper"

class Recipes::UpdateOrForkFromAgentTest < ActiveSupport::TestCase
  setup do
    @owner = users(:one)
    @other = users(:two)
  end

  test "updates owned recipe in place" do
    recipe = recipes(:one)
    assert_equal @owner.id, recipe.user_id

    payload = {
      "recipe_id" => recipe.id,
      "name" => "Updated Fixture Cocktail",
      "description" => "Still a test",
      "tags" => ["citrus", "refreshing"],
      "steps" => ["Shake hard", "Double strain"],
      "ingredients" => [
        { "name" => "Gin", "quantity" => 60, "unit" => "ml" },
        { "name" => "Lime juice", "quantity" => 25, "unit" => "ml" }
      ],
      "glassware" => "Nick and Nora",
      "garnish" => "Peel"
    }

    assert_no_difference -> { Recipe.count } do
      result = Recipes::UpdateOrForkFromAgent.call(user: @owner, input: payload)
      assert_equal false, result.forked
      assert_equal recipe.id, result.recipe.id
    end

    recipe.reload
    assert_equal "Updated Fixture Cocktail", recipe.name
    assert_equal ["citrus", "refreshing"], recipe.tags
    assert_equal 2, recipe.recipe_ingredients.count
  end

  test "forks public recipe for another user" do
    source = recipes(:two)
    source.update!(is_public: true)

    payload = {
      "recipe_id" => source.id,
      "name" => "Forked Second",
      "description" => "Forked",
      "tags" => ["fork"],
      "steps" => ["Stir", "Serve"],
      "ingredients" => [
        { "name" => "Vermouth", "quantity" => 30, "unit" => "ml" },
        { "name" => "Whiskey", "quantity" => 60, "unit" => "ml" }
      ]
    }

    assert_difference -> { Recipe.count }, 1 do
      result = Recipes::UpdateOrForkFromAgent.call(user: @owner, input: payload)
      assert_equal true, result.forked
      assert_not_equal source.id, result.recipe.id
      assert_equal @owner.id, result.recipe.user_id
      assert_equal false, result.recipe.is_public?
    end
  end

  test "rejects private recipe from another user" do
    source = recipes(:two)
    source.update!(is_public: false)

    payload = {
      "recipe_id" => source.id,
      "name" => "Nope",
      "steps" => ["One"],
      "ingredients" => [{ "name" => "Gin", "quantity" => 45, "unit" => "ml" }]
    }

    error = assert_raises(Recipes::CreateFromAgent::ValidationError) do
      Recipes::UpdateOrForkFromAgent.call(user: @owner, input: payload)
    end
    assert_match(/cannot access/i, error.message)
  end
end
