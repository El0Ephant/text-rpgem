require 'io/console'
require_relative 'window.rb'
# system 'mode 100, 25'
# system 'cls'

def line_window(w, h)
  line = "┏"
  (w-2).times  do
    line.concat "━"
  end
  line.concat "┓\n"
  (h-2).times do
    line.concat "┃"
    (w-2).times do
      line.concat " "
    end
    line.concat "┃\n"
  end
  line.concat "┗"
  (w-2).times  do
    line.concat "━"
  end
  line.concat "┛"
  line
end

def get_key
  char = STDIN.getch.inspect[1..-2]
  case char
  when '\xE0H'
    'up'
  when '\xE0M'
    'right'
  when '\xE0P'
    'down'
  when '\xE0K'
    'left'
  when '\t'
    'tab'
  when '\r'
    'enter'
  else
    char
  end
end

def line_to_arr(line)
  res = []
  line.each_line(chomp: true) do |x|
    res.push(Array.new)
    x.each_char do |c|
      res.last.push(c)
    end
  end
  res
end

def control(win)
  x = 1
  y = 1
  last = win[x,y]
  win[x,y] = '╳'
  loop do

    win.win_print
    action = get_key
    case action
    when 'r'
      win.win_print
    when 'q'
      break
    when 'up'
      win[x,y] = last
      y = (y-1) % win.height
      last = win[x,y]
      win[x,y] = '╳'
    when 'right'
      win[x,y] = last
      x = (x+1) % win.width
      last = win[x,y]
      win[x,y] = '╳'
    when 'down'
      win[x,y] = last
      y = (y+1) % win.height
      last = win[x,y]
      win[x,y] = '╳'
    when 'left'
      win[x,y] = last
      x = (x-1) % win.width
      last = win[x,y]
      win[x,y] = '╳'
    else
      # type code here
    end
  end
end

def control1(win)
  loop do
    win.win_print
    action = get_key
    win.add_block(line_to_arr(action),1,1)
    case action
    when 'r'
      win.win_print
    when 'q'
      break
    else
      win.add_block([[1]],3,3)
    end
  end
end

w = Window.new(100,25)
w.add_block(line_to_arr(line_window(100, 25)),0,0)
#w.win_print

control(w)
#system 'pause'
#system 'pause >nul'
#ruby console_graphics.rb
