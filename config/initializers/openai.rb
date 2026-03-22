Rails.application.configure do
  config.x.openai = ActiveSupport::OrderedOptions.new unless config.x.respond_to?(:openai)

  config.x.openai.api_base = ENV.fetch("OPENAI_API_BASE", "https://api.openai.com/v1")
  config.x.openai.model = ENV.fetch("OPENAI_MODEL", "gpt-4.1-mini")
end
