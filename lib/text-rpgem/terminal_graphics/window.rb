require "io/console"

class Window
  def initialize(bars, values, ev_tr: nil)
    @body = Array.new(25) { Array.new(100) }
    add_block(line_to_arr("┏#{"━" * 64}┳━┳#{"━" * 31}┓\n#{"┃#{" " * 64}┃ ┃#{" " * 31}┃\n" * 14}┃#{" " * 64}┃ ┣#{"━" * 15}┳#{"━" * 15}┫\n#{"┃#{" " * 64}┃ ┃#{" " * 15}┃#{" " * 15}┃\n" * 8}┗#{"━" * 64}┻━┻#{"━" * 15}┻#{"━" * 15}┛"), 0, 0)
    @event_tree = ev_tr
    @bars = bars
    @values = values
    @is_panel_visible = false
    @cur_upper_line = 0
    # system 'cls' # Почистил терминал
    # print "\e[H\e[2J"
    print "\e[?25l" # Скрыл курсор терминала
  end

  def run
    # b = Bar.new("health", 100, 100)
    t1 = File.read("test.txt")
    create_text_buffer(t1)

    thr = nil
    loop do
      # add_block(line_to_arr(b.to_s), 68, 1)
      @bars.each_index do |i|
        add_block(line_to_arr(@bars[i].to_s), 68, 3 * i + 1)
      end
      @values.each_index do |i|
        add_block(line_to_arr(@values[i].to_s), i / 3 * 16 + 68, 3 * (i % 3) + 16)
      end
      add_block(line_to_arr("█\n█\n█\n█\n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n "), 66, 1)
      render
      case key_get
      when "up"
        thr.kill if !thr.nil? && thr.alive?
        move_text_line(-1)
      when "right"
        # do smth
      when "down"
        thr.kill if !thr.nil? && thr.alive?
        move_text_line(1)
      when "left"
        # do smth
      when "e", "у"
        thr = Thread.new { text_print(0.001) } if thr.nil? || !thr.alive?
      when "r", "к"
        if !thr.nil? && thr.alive?
          thr.kill
          move_text_line(0)
        end
      when "q", "й"
        print "\e[H\e[2J"
        break
      when "w", "ц"
        @bars[0].value += 1
      when "s", "ы"
        @bars[0].value -= 1
      else
        # type code here
      end
    end
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

  def return_size
    system "mode 100, 25"
    # print "\e[8;100;25t"
  end

  def show_choosing_panel
    @is_panel_visible = true
    add_block(line_to_arr("┏#{"━" * 62}┓\n#{"┃#{" " * 62}┃\n" * 12}┗#{"━" * 62}┛"), 1, 10)
  end

  def hide_choosing_panel
    @is_panel_visible = false
    add_block(Array.new(23, Array.new(64, " ")), 1, 1)
    move_text_line(0)
  end

  def render
    return_size
    print "\e[1;1H" # Перешел в буфере терминала на координату 1;1
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

  def text_print(sleep_time)
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
        r = @text[@cur_upper_line, line]
        r.push Array.new(62, " ")
        add_block(r, 2, 1)
        render
      else
        line += 1
      end
      x += 1
      break if x == @text.size
    end
  end

  def move_text_line(direction)
    if @cur_upper_line + direction <= @text.size - 23
      if @cur_upper_line + direction >= 0
        unless @is_panel_visible
          @cur_upper_line += direction
        else
          hide_choosing_panel
        end
        add_block(@text[@cur_upper_line, 23], 2, 1)
      end
    else
      unless @is_panel_visible
        add_block(@text[@cur_upper_line + 14, 23], 2, 1)
        show_choosing_panel
      end
    end
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
        res.last.push(c)
      end
    end
    res
  end
end

class Bar
  attr_reader :value

  def value=(val)
    if val > @max_value
      @value = @max_value
      return
    end
    if val.negative?
      @value = 0
      return
    end
    @value = val
  end

  def initialize(name, max_value, value)
    @name = name
    @max_value = max_value
    @value = value
  end

  def to_s
    light = 20 - @value * 20 / @max_value
    up =
      "┏━━━━━━━━━━━━━━━━━━━┓\n"
    down =
      "┗━━━━━━━━━━━━━━━━━━━┛"
    if light.positive?
      up[0] = "┌"
      down[0] = "└"
      (light - 1).times do |i|
        up[i + 1] = "─"
        down[i + 1] = "─"
      end
      if light == 20
        up[light] = "┐"
        down[light] = "┘"
      else
        up[light] = "┲"
        down[light] = "┺"
      end
    end
    format("%10s", @name) + up + format("%10d", @value) + down
  end
end

class Value
  attr_reader :value

  def value=(val)
    @value = val
  end

  def initialize(name, value)
    @name = name
    @value = value
  end

  def to_s
    format("%<name>15s\n%<value>15d", name:@name, value:@value)
  end

end

