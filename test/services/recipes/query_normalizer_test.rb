# frozen_string_literal: true

require "test_helper"

class Recipes::QueryNormalizerTest < ActiveSupport::TestCase
  test "strips common voice fillers" do
    assert_equal "gin sour", Recipes::QueryNormalizer.call("I want a gin sour")
    assert_equal "margarita", Recipes::QueryNormalizer.call("I'd like a margarita")
    assert_equal "negroni recipe", Recipes::QueryNormalizer.call("looking for negroni recipe")
  end

  test "collapses whitespace" do
    assert_equal "pisco sour", Recipes::QueryNormalizer.call("  pisco   sour  ")
  end

  test "passes through simple queries" do
    assert_equal "margarita", Recipes::QueryNormalizer.call("margarita")
  end
end
