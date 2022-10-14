require_relative 'window.rb'

w = Window.new(100,25)
# размеры окна - заглушка
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