# frozen_string_literal: false

require "io/console"
require_relative "escape_chars"
require_relative "../scenario/scenario"
require_relative "../scenario/counter"
require_relative "scroller"

# A class that represents the Windows terminal interface for text-based role-playing games
class Window
  # @param [Scenario] scenario
  def initialize(scenario, print_speed: 0.001)
    return_size
    EscapeChars.hide_cursor
    @print_speed = print_speed
    @body = Array.new(25) { Array.new(100) }
    add_block(line_to_arr(
                "┏#{"━" * 64}┳━┳#{"━" * 31}┓\n"\
                "#{"┃#{" " * 64}┃ ┃#{" " * 31}┃\n" * 14}"\
                "┃#{" " * 64}┃ ┣#{"━" * 15}┳#{"━" * 15}┫\n"\
                "#{"┃#{" " * 64}┃ ┃#{" " * 15}┃#{" " * 15}┃\n" * 8}"\
                "┗#{"━" * 64}┻━┻#{"━" * 15}┻#{"━" * 15}┛"
              ), 0, 0)
    @scenario = scenario
    @bars = {}
    @counters = {}
    @scenario.counters.each_pair do |k, v|
      if v.is_a? Bar
        @bars[k] = v
      else
        @counters[k] = v
      end
    end
    initialize_event
    validate_elements_number
    @print_thread = nil
  end

  def validate_elements_number
    raise RuntimeError.new("Too much bars for terminal interface") if @bars.count > 5
    raise RuntimeError.new("Too much counters for terminal interface") if @counters.count > 6
    raise RuntimeError.new("Too much options for terminal interface") if @routes.count > 6
  end

  def initialize_event
    create_text_buffer(@scenario.current.description)
    @scroller = Scroller.new @text.size
    @cur_upper_line = 0
    @is_panel_visible = false
    @routes = []
    @scenario.current.options.each_key do |k|
      @routes.push k
    end
    move_text_line(0)
    add_block(Array.new(23, Array.new(64, " ")), 1, 1)
  end

  def run
    show_help_panel
    loop do
      if @is_help_visible
        case key_get
        when "tab"
          hide_help_panel
        when "q", "й"
          EscapeChars.exit_app
          break
        else
          next
        end
      end
      update_bars
      update_counters
      render
      case key_get
      when "tab"
        show_help_panel
      when "up", "w", "ц"
        if print_thread_active?
          @print_thread&.kill
          move_line(0)
          next
        end
        move_line(-1)
      when "down", "s", "ы"
        if print_thread_active?
          @print_thread&.kill
          move_line(0)
          next
        end
        move_line(1)
      when "q", "й"
        EscapeChars.exit_app
        break
      when "enter", "f", "а"
        next if !@is_panel_visible || @scenario.current.options.empty?

        @scenario.next @routes[@cursor_pos].to_sym
        initialize_event
        invoke_text_printing
      else
        next
      end
    end
  end

  def print_thread_active?
    !@print_thread.nil? && @print_thread.alive?
  end

  def invoke_text_printing
    @print_thread = Thread.new { text_printing(@print_speed) } unless print_thread_active?
  end

  def update_bars
    i = 0
    @bars.each_pair do |k, v|
      add_block(line_to_arr(bar_to_s(k, v)), 68, 3 * i + 1)
      i += 1
    end
  end

  def update_counters
    i = 0
    @counters.each_pair do |k, v|
      add_block(line_to_arr(counter_to_s(k, v)), i / 3 * 16 + 68, 3 * (i % 3) + 16)
      i += 1
    end
  end

  def show_help_panel
    return_size
    @is_panel_visible = false
    @is_help_visible = true
    add_block(line_to_arr("┏#{"━" * 98}┓\n#{"┃#{" " * 98}┃\n" * 23}┗#{"━" * 98}┛\n"), 0, 0)
    add_block(line_to_arr(
                "Tab -> show/hide help (also return terminal size)\n"\
                "W, S, ↑, ↓ -> move text\n"\
                "F, Enter -> choose option\n"\
                "Q -> exit application"
              ), 1, 1)
    render
  end

  def hide_help_panel
    return_size
    @is_help_visible = false
    add_block(line_to_arr(
                "┏#{"━" * 64}┳━┳#{"━" * 31}┓\n"\
                "#{"┃#{" " * 64}┃ ┃#{" " * 31}┃\n" * 14}"\
                "┃#{" " * 64}┃ ┣#{"━" * 15}┳#{"━" * 15}┫\n"\
                "#{"┃#{" " * 64}┃ ┃#{" " * 15}┃#{" " * 15}┃\n" * 8}"\
                "┗#{"━" * 64}┻━┻#{"━" * 15}┻#{"━" * 15}┛"
              ), 0, 0)
    move_text_line(0)
    invoke_text_printing
  end

  def [](i, j)
    @body[j][i]
  end

  def []=(i, j, x)
    @body[j][i] = x
  end

  def add_block(arr, x, y)
    arr.size.times do |i|
      arr[i].size.times do |j|
        @body[y + i][x + j] = arr[i][j]
      end
    end
  end

  def add_highlighted_block(arr, x, y)
    arr.size.times do |i|
      arr[i].size.times do |j|
        @body[y + i][x + j] = arr[i][j]
      end
      @body[y + i][x] = EscapeChars.highlighter + @body[y + i][x]
      xx = x + arr[i].size - 1
      @body[y + i][xx] = @body[y + i][xx] + EscapeChars.normalizer
    end
  end

  def return_size
    system "mode 100, 25"
  end

  def move_line(direction)
    if @is_panel_visible
      if (@cursor_pos + direction).negative?
        hide_choosing_panel
        return
      end
      move_panel_cursor(direction)
    else
      if @text.size <= 9 || @cur_upper_line + direction > @text.size - 23
        show_choosing_panel
        return
      end
      move_text_line(direction)
    end
  end

  def move_text_line(direction)
    return if (@cur_upper_line + direction).negative?

    @scroller.move direction
    add_block(@scroller.result_arr, 66, 1)
    @cur_upper_line += direction
    add_block(@text[@cur_upper_line, 23], 2, 1)
  end

  def move_panel_cursor(direction)
    return if @cursor_pos + direction >= @routes.size

    add_block(line_to_arr(@scenario.current.options[@routes[@cursor_pos]]), 3, 11 + @cursor_pos * 2)
    @cursor_pos += direction
    add_highlighted_block(line_to_arr(@scenario.current.options[@routes[@cursor_pos]]), 3, 11 + @cursor_pos * 2)
  end

  def show_choosing_panel
    return if @routes.empty?

    @is_panel_visible = true
    r = [9, @text.size].min
    add_block(@text[-r, r], 2, 1)
    add_block(line_to_arr("┏#{"━" * 62}┓\n#{"┃#{" " * 62}┃\n" * 12}┗#{"━" * 62}┛"), 1, 10)
    @cursor_pos = 0
    @routes.each_index do |i|
      if i == @cursor_pos
        add_highlighted_block(line_to_arr(@scenario.current.options[@routes[i]]), 3, 11 + i * 2)
      else
        add_block(line_to_arr(@scenario.current.options[@routes[i]]), 3, 11 + i * 2)
      end
    end
  end

  def hide_choosing_panel
    @is_panel_visible = false
    add_block(Array.new(23, Array.new(64, " ")), 1, 1)
    move_text_line(0)
  end

  def render
    EscapeChars.move_cursor_to(x: 1, y: 1)
    line = ""
    (@body.size - 1).times do |x|
      @body[x].each do |y|
        line.concat y.to_s
      end
      line.concat "\n"
    end
    @body[@body.size - 1].each do |y|
      line.concat y.to_s
    end
    print line
  end

  def create_text_buffer(text)
    @text = []
    text.each_line(chomp: true) do |line|
      lc = line.chars
      (lc.size / 62 + 1).times do |k|
        arr = Array.new(62, " ")
        (lc.size - 62 * k < 62 ? lc.size - 62 * k : 62).times do |x|
          arr[x] = lc[x + 62 * k]
        end
        @text.push(arr)
      end
    end
  end

  def text_printing(sleep_time)
    add_block(Array.new(23, Array.new(64, " ")), 1, 1)
    x = 0
    line = 0
    loop do
      @text[x].each_index do |y|
        next unless @text[x][y] != " "

        @body[line + 1][y + 2] = @text[x][y]
        render
        sleep(sleep_time)
      end
      if x > 10 && x < @text.size - 12
        @cur_upper_line += 1
        @scroller.move(1)
        add_block(@scroller.result_arr, 66, 1)
        r = @text[@cur_upper_line, line]
        r&.push Array.new(62, " ")
        add_block(r, 2, 1)
        render
      else
        line += 1
      end
      x += 1
      break if x == @text.size
    end
    move_line(1)
    render
  end

  def key_get
    char = $stdin.getch.inspect[1..-2]
    case char
    when '\xE0H'
      "up"
    when '\xE0M'
      "right"
    when '\xE0P'
      "down"
    when '\xE0K'
      "left"
    when '\t'
      "tab"
    when '\r'
      "enter"
    else
      char
    end
  end

  def line_to_arr(line)
    res = []
    line.each_line(chomp: true) do |x|
      res.push([])
      x.each_char do |c|
        res.last&.push(c)
      end
    end
    res
  end
end

def bar_to_s(name, bar)
  heavy = bar.value * 20 / bar.max
  up =
    "┌───────────────────┐\n"
  down =
    "└───────────────────┘"
  if heavy.positive? || bar.value != bar.min
    heavy = [heavy, 1].max
    up[0] = "┏"
    down[0] = "┗"
    (heavy - 1).times do |i|
      up[i + 1] = "━"
      down[i + 1] = "━"
    end
    if heavy == 20
      up[heavy] = "┓"
      down[heavy] = "┛"
    else
      up[heavy] = "┱"
      down[heavy] = "┹"
    end
  end
  name = "#{name[0, 7]}..." if name.length > 10
  format("%10s", name) + up + format("\n%10d", bar.value) + down
end

def counter_to_s(name, counter)
  name = "#{name[0, 12]}..." if name.length > 15
  format("%<name>15s\n%<value>15d", name: name, value: counter.value)
end
