require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "create recipe with nested ingredients" do
    assert_difference("Recipe.count", 1) do
      assert_no_difference("Ingredient.count") do
        post recipes_path, params: {
          recipe: {
            name: "Paper Plane",
            description: "",
            glassware: "",
            garnish: "",
            tags: "citrus",
            steps: "Shake\nStrain",
            recipe_ingredients_attributes: {
              "0" => {
                ingredient_id: ingredients(:gin).id,
                amount: "0.75",
                unit: "oz"
              }
            }
          }
        }
      end
    end

    assert_redirected_to recipe_path(Recipe.order(:created_at).last)
    follow_redirect!
    assert_response :success
  end

  test "new redirects to voice on mobile user agent" do
    get new_recipe_path, headers: { "User-Agent" => "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)" }

    assert_redirected_to voice_path
  end

  test "edit redirects to voice on mobile user agent" do
    recipe = recipes(:one)
    get edit_recipe_path(recipe), headers: { "User-Agent" => "Mozilla/5.0 (Android 14; Mobile)" }

    assert_redirected_to voice_path
  end

  test "owner can destroy own recipe" do
    recipe = recipes(:one)

    assert_difference("Recipe.count", -1) do
      delete recipe_path(recipe)
    end

    assert_redirected_to recipes_path
  end

  test "user cannot destroy another users recipe" do
    recipe = recipes(:two)

    assert_no_difference("Recipe.count") do
      delete recipe_path(recipe)
    end

    assert_redirected_to recipes_path
  end
end
