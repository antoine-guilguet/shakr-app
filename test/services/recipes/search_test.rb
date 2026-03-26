# frozen_string_literal: true

require "test_helper"

class Recipes::SearchTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @other = users(:two)
  end

  test "ranks name match above recency when description matches" do
    Recipe.create!(
      user: @other,
      name: "Margarita",
      description: "ok",
      is_public: true,
      tags: [],
      steps: [],
      updated_at: 3.days.ago
    )
    Recipe.create!(
      user: @other,
      name: "Other Drink",
      description: "margarita style cocktail",
      is_public: true,
      tags: [],
      steps: [],
      updated_at: 1.hour.ago
    )

    rel = Recipe.where(is_public: true)
    found = Recipes::Search.call(relation: rel, query: "margarita")

    assert_equal "Margarita", found.name
  end

  test "finds recipe by ingredient name" do
    recipe = Recipe.create!(
      user: @other,
      name: "House Special",
      description: "",
      is_public: true,
      tags: [],
      steps: []
    )
    recipe.recipe_ingredients.create!(
      ingredient: ingredients(:gin),
      amount: 45,
      unit: "ml",
      position: 0
    )

    rel = Recipe.where(is_public: true)
    found = Recipes::Search.call(relation: rel, query: "gin")

    assert_equal recipe.id, found.id
  end
end
