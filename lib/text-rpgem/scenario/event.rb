# frozen_string_literal: true

require_relative "../parser/parser"

class Event
  # @param [Hash<Counter>]
  # @param [String] path
  def initialize(path)
    @description, @options = Parser.parse_event(path)
    @route_lambda = ->(route_name) { return @routes[route_name] }
  end

  attr_reader :description, :options, :route_lambda

  # @param [Hash<Event>] routes
  def routes(routes)
    @routes = routes
    self
  end

  # @param [Lambda] lambda
  def routes_by_lambda(lambda)
    @route_lambda = lambda
    self
  end
end
