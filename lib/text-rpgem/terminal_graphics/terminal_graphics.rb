

require_relative "window"
require "io/console"
b = Bar.new("health", 100, 100)
v = Value.new("stat", 100)
w = Window.new([b,b,b,b,b], [v,v,v,v,v])
w.run

# in cmd:
# ruby terminal_graphics.rb
# Controls:
# q - exit
# e - start animation
# r - stop animation
# arrow up - move text up
# arrow down - move text down
# w - inc health
# s - dec health
