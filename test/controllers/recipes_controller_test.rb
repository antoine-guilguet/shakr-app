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
end
