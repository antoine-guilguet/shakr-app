require "openai"

Rails.application.configure do
  config.x.openai = ActiveSupport::OrderedOptions.new unless config.x.respond_to?(:openai)

  config.x.openai.api_base = ENV.fetch("OPENAI_API_BASE", "https://api.openai.com/v1")
  config.x.openai.model = ENV.fetch("OPENAI_MODEL", "gpt-4.1-mini")
  config.x.openai.realtime_model = ENV.fetch("OPENAI_REALTIME_MODEL", "gpt-realtime")
end

OpenAI.configure do |config|
  config.access_token = ENV["OPENAI_API_KEY"]
  config.uri_base = Rails.application.config.x.openai.api_base
  config.log_errors = Rails.env.development?
end
