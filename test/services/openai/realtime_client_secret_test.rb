# frozen_string_literal: true

require "test_helper"

class Openai::RealtimeClientSecretTest < ActiveSupport::TestCase
  FakeClient = Struct.new(:captured_parameters) do
    def json_post(path:, parameters:)
      self.captured_parameters = parameters
      {
        "value" => "ephemeral_test_key",
        "expires_at" => Time.current.iso8601
      }
    end
  end

  test "includes ui_state_update in realtime tools" do
    original_api_key = ENV["OPENAI_API_KEY"]
    ENV["OPENAI_API_KEY"] = "test-openai-key"

    fake_client = FakeClient.new
    original_new = OpenAI::Client.method(:new)

    OpenAI::Client.define_singleton_method(:new) do |**_kwargs|
      fake_client
    end

    Openai::RealtimeClientSecret.call
    tools = Array(fake_client.captured_parameters.dig(:session, :tools))
    tool_names = tools.map { |tool| tool[:name] }

    assert_includes tool_names, "ui_state_update"
    assert_includes tool_names, "update_recipe"
  ensure
    ENV["OPENAI_API_KEY"] = original_api_key
    OpenAI::Client.define_singleton_method(:new) do |**kwargs|
      original_new.call(**kwargs)
    end
  end
end
