require "test_helper"

class Agent::ToolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    sign_in @user
  end

  def with_stubbed_recipe_generator(callable)
    original = RecipeGenerator.method(:call)
    RecipeGenerator.define_singleton_method(:call) do |**kwargs|
      callable.call(**kwargs)
    end
    yield
  ensure
    RecipeGenerator.define_singleton_method(:call) do |**kwargs|
      original.call(**kwargs)
    end
  end

  test "recipes_search can return a public recipe" do
    Recipe.create!(
      user: @other_user,
      name: "Public Margarita",
      description: "A bright classic",
      is_public: true,
      tags: [ "citrus" ],
      steps: [ "Shake", "Strain" ]
    )

    post agent_tool_path(name: "recipes_search"),
      params: { query: "margarita", visibility: "public" },
      as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal true, body["found"]
    assert_equal "Public Margarita", body.dig("recipe", "name")
    assert_equal true, body.dig("recipe", "is_public")
  end

  test "recipes_search returns ingredients and steps_preview for slider UI" do
    recipe = Recipe.create!(
      user: @user,
      name: "Slider Sour",
      description: "Voice slider fixture",
      is_public: false,
      tags: [ "test" ],
      steps: [ "Dry shake egg white", "Shake with ice and fine strain" ]
    )
    RecipeIngredient.create!(
      recipe: recipe,
      ingredient: ingredients(:gin),
      amount: 45,
      unit: "ml",
      position: 0
    )
    RecipeIngredient.create!(
      recipe: recipe,
      ingredient: ingredients(:lemon),
      amount: 25,
      unit: "ml",
      position: 1
    )

    post agent_tool_path(name: "recipes_search"),
      params: { query: "Slider Sour", visibility: "private" },
      as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal true, body["found"]
    ingredients = body.dig("recipe", "ingredients")
    assert ingredients.is_a?(Array)
    assert(ingredients.any? { |line| line.to_s.include?("Gin") })
    assert_equal [ "Dry shake egg white", "Shake with ice and fine strain" ], body.dig("recipe", "steps_preview")
  end

  test "recipes_search can return the current user's private recipe" do
    Recipe.create!(
      user: @user,
      name: "Secret Negroni",
      description: "My private spec",
      is_public: false,
      tags: [ "bitter" ],
      steps: [ "Stir", "Strain" ]
    )

    post agent_tool_path(name: "recipes_search"),
      params: { query: "negroni", visibility: "private" },
      as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal true, body["found"]
    assert_equal "Secret Negroni", body.dig("recipe", "name")
    assert_equal false, body.dig("recipe", "is_public")
  end

  test "recipes_search never returns another user's private recipe" do
    Recipe.create!(
      user: @other_user,
      name: "Other User Secret",
      description: "Do not leak",
      is_public: false,
      tags: [ "private" ],
      steps: [ "Stir" ]
    )

    post agent_tool_path(name: "recipes_search"),
      params: { query: "Other User Secret", visibility: "any" },
      as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal false, body["found"]
  end

  test "recipes_search returns found false when nothing matches" do
    post agent_tool_path(name: "recipes_search"),
      params: { query: "definitely-not-a-recipe-name", visibility: "any" },
      as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal false, body["found"]
  end

  test "recipes_search normalizes noisy voice-style query" do
    Recipe.create!(
      user: @other_user,
      name: "Pisco Sour",
      description: "Classic",
      is_public: true,
      tags: [ "sour" ],
      steps: [ "Shake" ]
    )

    post agent_tool_path(name: "recipes_search"),
      params: { query: "I want a pisco sour", visibility: "public" },
      as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal true, body["found"]
    assert_equal "Pisco Sour", body.dig("recipe", "name")
  end

  test "create_ai_recipe returns a draft recipe for a valid prompt" do
    fake_attributes = {
      name: "Draft Daiquiri",
      description: "Crisp and bright.",
      tags: [ "rum", "citrus" ],
      ingredients: [
        { name: "White rum", quantity: 45, unit: "ml" },
        { name: "Lime juice", quantity: 25, unit: "ml" }
      ],
      steps: [ "Shake with ice.", "Strain into a chilled coupe." ],
      glassware: "Coupe",
      garnish: "Lime wheel"
    }

    with_stubbed_recipe_generator(->(**) { fake_attributes }) do
      post agent_tool_path(name: "create_ai_recipe"),
        params: { prompt: "A rum sour, not too sweet" },
        as: :json
    end

    assert_response :success
    body = response.parsed_body
    assert_equal true, body["ok"]
    assert_equal "Draft Daiquiri", body.dig("recipe", "name")
    assert_equal "Coupe", body.dig("recipe", "glassware")
    assert_equal 2, Array(body.dig("recipe", "ingredients")).length
  end

  test "create_ai_recipe rejects blank prompt" do
    post agent_tool_path(name: "create_ai_recipe"),
      params: { prompt: " " },
      as: :json

    assert_response :unprocessable_entity
    body = response.parsed_body
    assert_match(/prompt is required/i, body["error"].to_s)
  end

  test "create_ai_recipe surfaces generator errors as ok false" do
    with_stubbed_recipe_generator(->(**) { raise RecipeGenerator::Error, "AI down" }) do
      post agent_tool_path(name: "create_ai_recipe"),
        params: { prompt: "Anything" },
        as: :json
    end

    assert_response :success
    body = response.parsed_body
    assert_equal false, body["ok"]
    assert_equal "AI down", body["error"]
  end

  test "ui_state_update returns summary and actions payload" do
    post agent_tool_path(name: "ui_state_update"),
      params: {
        summary: "You asked for a low sugar sour.",
        actions: [
          { id: "make_one", label: "Suggest one", utterance: "Suggest one" }
        ],
        recipe: nil
      },
      as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal true, body["ok"]
    assert_equal "You asked for a low sugar sour.", body["summary"]
    assert_equal 1, Array(body["actions"]).length
    assert_nil body["recipe"]
  end
end
