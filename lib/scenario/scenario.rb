# frozen_string_literal: true

require_relative "event"
require_relative "counter"

class Scenario
  # @param [Hash<Counter>] counters
  # @param [Hash<Event>] events
  def initialize(events:, counters: {})
    @events = events
    @current = events.first
    @counters = counters
    yield events, counters
  end

  attr_reader :current

  # @param [String] option
  def next(option)
    @current = @current.route_lambda(option)
  end
end

# demo
demo_default = Scenario.new(
  events: {
    beginning: Event.new("path"),
    right: Event.new("path"),
    left: Event.new("path"),
    forest: Event.new("path"),
    cave: Event.new("path"),
    river: Event.new("path")
  }
) do |events|
  events[:beginning].routes(
    {
      left: events[:left].routes(
        {
          river: events[:river],
          forest: events[:forest]
        }
      ),
      right: events[:right].routes(
        {
          cave: events[:cave]
        }
      )
    }
  )
end

demo_counters = Scenario.new(
  events: {
    first: Event.new("path"),
    second: Event.new("path"),
    happy_end: Event.new("path"),
    game_over: Event.new("path")
  },
  counters: {
    hp: Counter.new(2)
  }
) do |events, counters|
  events[:first].routes_lambda(
    lambda do |option|
      case option
      when :bad then counters[:hp].value -= 1
      when :good then counters[:hp].value += 1
      end
      return events[:second].routes_lambda(
        lambda do |option|
          case option
          when :bad then counters[:hp].value -= 1
          when :good then counters[:hp].value += 1
          end
          return (counters[:hp].value).positive? ? events[:happy_end] : events[:game_over]
        end
      )
    end
  )
end