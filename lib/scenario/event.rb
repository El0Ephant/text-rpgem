# frozen_string_literal: true

class Event
  # @param [Hash<Counter>]
  # @param [String] path
  def initialize(path)
    # Parser.parse_event(path)
    @description = "description_placeholder" # TODO: collaborate with parser
    @options = { right: "Пойти направо", left: "Пойти налево" } # TODO: collaborate with parser
    @routes = { right: nil, left: nil }
    @route_lambda = ->(route_name) { return @routes[route_name] }
  end

  # @param [Hash<Event>] routes
  def routes(routes)
    @routes = routes
    self
  end

  # @param [Lambda] lambda
  def routes_lambda(lambda)
    @route_lambda = lambda
    self
  end
end
