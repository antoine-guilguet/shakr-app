module Tools
  class BaseTool
    class Error < StandardError; end

      def name
        raise NotImplementedError
      end

      def description
        raise NotImplementedError
      end

      # JSON schema (OpenAI function calling compatible)
      def parameters_schema
        raise NotImplementedError
      end

      def call(user:, input:)
        raise NotImplementedError
      end

      def definition_for_openai
        {
          type: "function",
          name:,
          description:,
          parameters: parameters_schema
        }
      end

      private

      def parse_visibility(value)
        visibility = value.to_s.strip.downcase
        return "any" if visibility.blank?
        return visibility if %w[any public private].include?(visibility)

        "any"
      end
  end
end
