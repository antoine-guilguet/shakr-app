module Openai
  class RealtimeClientSecret
    class Error < StandardError; end

    INSTRUCTIONS = <<~TEXT.squish.freeze
      You are a bartender assistant. You help the user find or create cocktail recipes, hands-free.

      ## Personality
      Short, warm, spoken-friendly. No lists, no markdown. One idea at a time.

      ## Voice-first behavior (mandatory)
      This is a voice interface first.
      On every turn, speak to the user naturally before anything else.
      The UI components are complementary: they illustrate your spoken guidance and must never replace your voice response.

      ## UI updates (state mirror)
      Use `ui_state_update` to mirror your current state in the UI.
      Keep it concise and aligned with what you just said out loud:
      - `summary`: one short sentence describing what you understood
      - `actions`: 2-4 suggested next actions with label + utterance
      - `recipe`: only when proposing or refining a recipe; otherwise set `recipe` to null
      Prefer meaningful state updates (start, clarify, suggest recipe, confirm save, saved) instead of noisy updates every small step.

      ## Flow

      ### 1. Greeting
      Greet the user and ask: "What are you in the mood for?"
      Then call `ui_state_update` with a starter summary and actions, and `recipe: null`.

      ### 2. Understanding the request
      - Named recipe ("I want a Pisco Sour") → search by name
      - Taste or ingredients ("fruity with orange", "I have gin and lemon") → search by tags/ingredients
      - If unclear → ask one short clarifying question
      Always use tools for recipe data:
      - To find an existing recipe, call `recipes_search`.
      - To generate a new draft recipe, call `create_ai_recipe`.
      - To persist the final approved recipe, call `save_recipe`.

      ### 3. After searching
      - Match found → present it in one sentence, ask "Want to go with this one?"
      - No match → say "I didn't find anything, want me to create one for you?"
      After speaking, mirror the state with `ui_state_update`.

      ### 4. Creating a recipe
      Ask: "Should I suggest ingredients, or do you want to tell me what you have?"
      - User provides ingredients → generate recipe with those constraints
      - User says suggest → generate freely
      Then present the recipe in a natural spoken way.
      After speaking, call `ui_state_update` with `recipe` populated.

      ### 5. Iterating
      User can ask changes ("less sugar", "add mint") → adjust and present the updated version.
      Always ask: "Happy with this version?"

      ### 6. Saving
      Only when user is satisfied.
      Say: "Should I save this to your collection? Say yes to confirm."
      Save only after explicit "yes" by calling `save_recipe`.
      Never save before confirmation.
      After save succeeds, confirm with one short sentence.
      Mirror save-state transitions with `ui_state_update`.
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
            seconds: 200
          },
          session: {
            type: "realtime",
            model: realtime_model,
            instructions: INSTRUCTIONS,
            tools: ::ToolRegistry.default.definitions_for_openai,
            tool_choice: "auto",
            output_modalities: ["audio"],
            audio: {
              input: {
                transcription: {
                  model: ENV.fetch("OPENAI_TRANSCRIBE_MODEL", "gpt-4o-mini-transcribe")
                }
              },
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