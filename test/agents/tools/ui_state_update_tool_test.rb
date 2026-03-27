# frozen_string_literal: true

require "test_helper"

class UiStateUpdateToolTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "ui_state_update returns normalized state payload" do
    post agent_tool_path(name: "ui_state_update"),
      params: {
        summary: "You want something citrus-forward.",
        phase: "clarifying",
        actions: [
          { id: "suggest_recipe", label: "Suggest one", utterance: "Suggest one" },
          { id: "", label: "Invalid", utterance: "Ignore me" }
        ],
        recipe: {
          name: "House Gimlet",
          description: "Bright and tart",
          ingredients: ["50 ml gin", "25 ml lime juice"],
          steps_preview: ["Shake with ice", "Fine strain"]
        }
      },
      as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal true, body["ok"]
    assert_equal "You want something citrus-forward.", body["summary"]
    assert_equal "clarifying", body["phase"]
    assert_equal 1, Array(body["actions"]).length
    assert_equal "House Gimlet", body.dig("recipe", "name")
  end

  test "ui_state_update requires at least one state field" do
    post agent_tool_path(name: "ui_state_update"), params: {}, as: :json

    assert_response :unprocessable_entity
    body = response.parsed_body
    assert_match(/at least one of/i, body["error"].to_s)
  end
end
