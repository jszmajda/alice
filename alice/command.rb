class Command

    include Mongoid::Document

    field :name
    field :verbs, type: Array, default: []
    field :indicators, type: Array, default: []
    field :stop_words, type: Array, default: []
    field :handler_class
    field :handler_method
    field :response_kind, default: :message

    index({ indicators: 1 }, { unique: true })
    index({ stop_words: 1 }, { unique: true })

    validates_uniqueness_of :name
    validates_presence_of :name, :indicators, :handler_class

    attr_accessor :message, :terms

    def self.default
      Command.new(handler_class: Handlers::Unknown)
    end

    def self.indicators_from(message)
      Alice::Parser::NgramFactory.omnigrams_from(message)
    end

    def self.best_match(matches, indicators)
      matches.sort do |a,b|
        (a.indicators & indicators).count <=> (b.indicators & indicators).count
      end.last
    end

    def self.from(message)
      message = message.downcase.gsub(/[^a-zA-Z0-9\!\/\\\s]/, ' ')
      indicators = indicators_from(message)
      matches = with_indicators(indicators).without_stopwords(indicators)
      match = best_match(matches, indicators) || default
      match.message = message
      match
    end

    def self.process(message)
      from(message).invoke!
    end

    def self.with_indicators(indicators)
      Command.in(indicators: indicators)
    end

    def self.without_stopwords(indicators)
      Command.not_in(stop_words: indicators)
    end

    def invoke!
      return false unless self.handler_class
      eval(self.handler_class).new(
        method: self.handler_method || :process,
        raw_command: self.message
      ).process
    end

    def terms
      @terms || TermList.new(self.indicators)
    end

    def terms=(words)
      @terms = TermList.new(words)
    end

    class TermList
      attr_accessor :words
      def initialize(terms=[])
        self.words = convert(terms)
      end

      def <<(terms)
        self.words << convert(terms)
        self.words = self.words.flatten.uniq
      end

      def convert(terms)
        [
          terms.map(&:downcase),
          terms.map{|term| Lingua.stemmer(term.downcase)}
        ].flatten.uniq
      end

      def to_a
        self.words
      end

    end


end