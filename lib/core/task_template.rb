module Minionizer
  class TaskTemplate
    attr_reader :session, :options

    def initialize(session, options = {})
      @session = session
      @options = options.with_indifferent_access
    end

    def method_missing(method_name, *arguments, &block)
      if options.key?(method_name)
        options[method_name]
      else
        super
      end
    end

    def respond_to?(method_name, include_private = false)
      options.key?(method_name) || super
    end

  end
end


