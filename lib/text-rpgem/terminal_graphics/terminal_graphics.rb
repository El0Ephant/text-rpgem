# frozen_string_literal: true

require_relative "window"
require_relative "../parser/parser"
require_relative "../scenario/scenario"
require_relative "../scenario/event"

test_scenario = Scenario.new(
  events: {
    question: Event.new("1.txt"),
    more_text: Event.new("1_1.txt"),
    even_more_text: Event.new("1_1_1.txt"),
    less_text: Event.new("1_2.txt"),
  },
  counters: {
    Health: Bar.new(100, 100),
    Mana: Bar.new(100, 150),
    Coins: Counter.new(0),
  }
) do |events|
  events[:question].routes(
    {
      opt1: events[:more_text].routes(
        {
          opt1: events[:even_more_text],
          opt2: events[:less_text],
        }
      ),
      opt2: events[:less_text],
    }
  )
end
w = Window.new(test_scenario)
w.run

# in cmd:
# ruby terminal_graphics.rb
