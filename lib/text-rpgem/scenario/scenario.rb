# frozen_string_literal: true

require_relative "event"
require_relative "counter"

class Scenario
  # @param [Hash<Counter>] counters
  # @param [Hash<Event>] events
  def initialize(events:, counters: {})
    @events = events
    @current = events.first[1]
    @counters = counters
    yield events, counters
  end

  attr_reader :current

  # @param [Symbol] option
  def next(option)
    @current = @current.route_lambda.call(option)
  end

  def not_print
    puts @current.description
    puts @current.options.each { |opt| puts opt[1] }
  end
end