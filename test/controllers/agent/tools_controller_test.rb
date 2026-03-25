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
      tags: ["citrus"],
      steps: ["Shake", "Strain"]
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

  test "recipes_search can return the current user's private recipe" do
    Recipe.create!(
      user: @user,
      name: "Secret Negroni",
      description: "My private spec",
      is_public: false,
      tags: ["bitter"],
      steps: ["Stir", "Strain"]
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
      tags: ["private"],
      steps: ["Stir"]
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

  test "create_ai_recipe returns a draft recipe for a valid prompt" do
    fake_attributes = {
      name: "Draft Daiquiri",
      description: "Crisp and bright.",
      tags: ["rum", "citrus"],
      ingredients: [
        { name: "White rum", quantity: 45, unit: "ml" },
        { name: "Lime juice", quantity: 25, unit: "ml" }
      ],
      steps: ["Shake with ice.", "Strain into a chilled coupe."],
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
end

