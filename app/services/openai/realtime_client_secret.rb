module Openai
  class RealtimeClientSecret
    class Error < StandardError; end

    INSTRUCTIONS = <<~TEXT.squish.freeze
      You are Shakr, a friendly cocktail expert in the Shakr app.
      Help the user explore flavors and create cocktails. Keep spoken replies concise and conversational.
    TEXT

    def self.call
      new.call
    end

    def call
      ensure_openai_configured!

      api_base = Rails.application.config.x.openai.api_base

      payload = openai_client.json_post(
        path: "/realtime/client_secrets",
        parameters: {
          expires_after: {
            anchor: "created_at",
            seconds: 600
          },
          session: {
            type: "realtime",
            model: realtime_model,
            instructions: INSTRUCTIONS,
            audio: {
              output: {
                voice: "marin"
              }
            }
          }
        }
      )

      value = payload["value"]
      raise Error, "OpenAI returned an unexpected response." if value.blank?

      {
        ephemeral_key: value,
        expires_at: payload["expires_at"],
        realtime_calls_url: "#{api_base}/realtime/calls"
      }
    rescue Faraday::Error => e
      body = e.response&.dig(:body)
      body = body.to_json if body.is_a?(Hash)
      Rails.logger.error("[Openai::RealtimeClientSecret] #{e.class} body=#{body.to_s.slice(0, 800)}")
      status = e.response&.dig(:status)
      raise Error, "OpenAI could not start a voice session#{status ? " (#{status})" : ""}."
    end

    private

    def openai_client
      OpenAI::Client.new(request_timeout: 30)
    end

    def realtime_model
      Rails.configuration.x.openai&.realtime_model || ENV.fetch("OPENAI_REALTIME_MODEL", "gpt-realtime")
    end

    def ensure_openai_configured!
      return if ENV["OPENAI_API_KEY"].present?

      Rails.logger.error("[Openai::RealtimeClientSecret] OPENAI_API_KEY is not set")
      raise Error, "Voice assistant is not configured (missing API key)."
    end
  end
end
