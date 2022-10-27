# frozen_string_literal: true

require_relative "event"
require_relative "counter"

class Scenario
  # @param [Hash<Counter>] counters
  # @param [Hash<Counter>] hidden_counters
  # @param [Hash<Event>] events
  def initialize(events:, counters: {}, hidden_counters: {})
    @events = events
    @current = events.first[1]
    @counters = counters
    @hidden_counters = hidden_counters
    yield events, counters, hidden_counters
  end

  attr_reader :current

  # @param [Symbol] option
  def next(option)
    @current = @current.route_lambda.call(option)
  end
end

