# frozen_string_literal: true

require "test_helper"

class SaveRecipeToolTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "save_recipe persists recipe and ingredients" do
    payload = {
      name: "Saved By Agent",
      description: "Silky and balanced",
      tags: ["rum", "tropical"],
      steps: ["Shake with ice", "Strain into chilled glass"],
      ingredients: [
        { name: "White rum", quantity: 45, unit: "ml" },
        { name: "Lime juice", quantity: 20, unit: "ml" }
      ],
      glassware: "Coupe",
      garnish: "Lime wheel",
      is_public: false
    }

    assert_difference -> { Recipe.count }, 1 do
      assert_difference -> { RecipeIngredient.count }, 2 do
        post agent_tool_path(name: "save_recipe"), params: payload, as: :json
      end
    end

    assert_response :success
    body = response.parsed_body
    assert_equal true, body["ok"]
    assert_equal "Saved By Agent", body.dig("recipe", "name")
    assert body.dig("recipe", "id").present?
    assert body.dig("recipe", "url").to_s.include?("/recipes/")
  end

  test "save_recipe returns structured error for invalid payload" do
    post agent_tool_path(name: "save_recipe"),
      params: {
        name: "Invalid Draft",
        steps: ["Shake"],
        ingredients: [{ name: "Gin", quantity: 45, unit: "liter" }]
      },
      as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal false, body["ok"]
    assert_match(/unit must be one of/i, body["error"].to_s)
  end

  test "tool registry exposes save_recipe definition" do
    names = ToolRegistry.default.definitions_for_openai.map { |d| d[:name] }
    assert_includes names, "save_recipe"
  end
end
