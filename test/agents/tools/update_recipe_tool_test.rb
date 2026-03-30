# frozen_string_literal: true

require "test_helper"

class UpdateRecipeToolTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "update_recipe updates owned recipe" do
    recipe = recipes(:one)
    payload = {
      recipe_id: recipe.id,
      name: "Tool Updated Name",
      description: "Via tool",
      tags: ["tool"],
      steps: ["Step one", "Step two"],
      ingredients: [
        { name: "Gin", quantity: 45, unit: "ml" },
        { name: "Tonic", quantity: 100, unit: "ml" }
      ]
    }

    assert_no_difference -> { Recipe.count } do
      post agent_tool_path(name: "update_recipe"), params: payload, as: :json
    end

    assert_response :success
    body = response.parsed_body
    assert_equal true, body["ok"]
    assert_equal false, body["forked"]
    assert_equal recipe.id, body.dig("recipe", "id")
    assert_equal "Tool Updated Name", body.dig("recipe", "name")
    assert body.dig("recipe", "ingredients").is_a?(Array)
    assert body.dig("recipe", "steps_preview").is_a?(Array)
  end

  test "update_recipe forks public recipe from another user" do
    source = recipes(:two)
    source.update!(is_public: true)

    payload = {
      recipe_id: source.id,
      name: "Forked via tool",
      steps: ["Mix", "Pour"],
      ingredients: [
        { name: "Rum", quantity: 50, unit: "ml" },
        { name: "Lime", quantity: 20, unit: "ml" }
      ]
    }

    assert_difference -> { Recipe.count }, 1 do
      post agent_tool_path(name: "update_recipe"), params: payload, as: :json
    end

    assert_response :success
    body = response.parsed_body
    assert_equal true, body["ok"]
    assert_equal true, body["forked"]
    assert_not_equal source.id, body.dig("recipe", "id")
  end

  test "update_recipe returns structured error for invalid payload" do
    recipe = recipes(:one)
    post agent_tool_path(name: "update_recipe"),
      params: {
        recipe_id: recipe.id,
        name: "Bad",
        steps: ["Shake"],
        ingredients: [{ name: "Gin", quantity: 45, unit: "liter" }]
      },
      as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal false, body["ok"]
    assert_match(/unit must be one of/i, body["error"].to_s)
  end

  test "tool registry exposes update_recipe definition" do
    names = ToolRegistry.default.definitions_for_openai.map { |d| d[:name] }
    assert_includes names, "update_recipe"
  end
end
