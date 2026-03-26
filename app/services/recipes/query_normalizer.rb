# frozen_string_literal: true

module Recipes
  # Strips common voice / filler prefixes so FTS queries are not polluted.
  class QueryNormalizer
    # Phrases removed only when they appear at the start of the string (after whitespace).
    LEADING_FILLERS = [
      /\A(i\s+want|i'?d\s+like|i\s+would\s+like|can\s+you\s+find|looking\s+for|find\s+me|show\s+me|give\s+me)\s+/i,
      /\A(something|something\s+like)\s+/i
    ].freeze

    # Articles removed only at the very beginning after fillers are stripped.
    LEADING_ARTICLE = /\A(the|a|an)\s+/i.freeze

    def self.call(query)
      new(query).call
    end

    def initialize(query)
      @query = query
    end

    def call
      s = @query.to_s.strip.downcase
      s = s.gsub(/\s+/, " ")
      8.times do
        before = s
        LEADING_FILLERS.each { |rx| s = s.sub(rx, "") }
        s = s.sub(LEADING_ARTICLE, "")
        break if s == before
      end
      s.strip
    end
  end
end
