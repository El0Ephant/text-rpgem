require 'io/console'

class Window
  attr_reader :width, :height

  def initialize(w, h, ev_tr: nil, bars: nil)
    @body = Array.new(h) {Array.new(w)}
    add_block(line_to_arr(
                "┏"+"━"*64+"┳━┳"+"━"*31+"┓\n"+
                  ("┃"+" "*64+"┃ ┃"+" "*31+"┃\n")*23+
                  "┗"+"━"*64+"┻━┻"+"━"*31+"┛\n"
              ), 0, 0)
    @width = w
    @height = h
    @event_tree = ev_tr
    @bars = bars
    @cur_upper_line = 0
    #system 'cls' # Почистил терминал
    #print "\e[H\e[2J"
    print "\e[?25l" # Скрыл курсор терминала
  end

  def run
    b = Bar.new("health",100,100)
    t1 = File.read('C:\.Projects\text-rpgem\lib\text-rpgem\console_graphics\test.txt')
    create_text_buffer(t1)
    #move_text_line(0)
    thr = nil
    loop do
      add_block(line_to_arr(b.to_s),68,1)
      add_block(line_to_arr("█\n█\n█\n█"),66,1)
      render
      case get_key
      when 'up'
        if !thr.nil? && thr.alive?
          thr.kill
        end
        move_text_line(-1)
      when 'right'
      when 'down'
        if !thr.nil? && thr.alive?
          thr.kill
        end
        move_text_line(1)
      when 'left'
      when 'e','у'
        if thr.nil? || !thr.alive?
          thr = Thread.new {text_print(0.001)}
        end
      when 'r','к'
        if !thr.nil? && thr.alive?
          thr.kill
          move_text_line(0)
        end
        render
      when 'q','й'
        print "\e[H\e[2J"
        break
      when 'w','ц'
        b.value = b.value + 1
      when 's','ы'
        b.value = b.value - 1
      else
        # type code here
      end
    end
  end

  def [] (i, j)
    @body[j][i]
  end
  def []= (i, j, x)
    @body[j][i] = x
  end
  def add_block(arr, x, y)
    arr.size.times do |i|
      arr[i].size.times do |j|
        @body[y+i][x+j] = arr[i][j]
      end
    end
  end

  def return_size
    system 'mode ' + @width.to_s + ', ' + @height.to_s
  end

  def render
    return_size
    print "\e[1;1H" # Перешел в буфере терминала на координату 1;1
    line = ''
    (@body.size-1).times do |x|
      @body[x].each do |y|
        line.concat y.to_s
      end
      line.concat "\n"
    end
    @body[@body.size-1].each do |y|
      line.concat y.to_s
    end
    print line
  end

  def create_text_buffer(text)
    @text = []
    text.each_line(chomp: true) do |line|
      lc = line.chars
      (lc.size/62 + 1).times do |k|
        arr = Array.new(62, ' ')
        (62>lc.size-62*k ?  lc.size-62*k : 62).times do |x|
          arr[x]= lc[x+62*k]
        end
        @text.push(arr)
      end
    end
  end

  def text_print(sleep_time)
    add_block(Array.new(23,Array.new(62, ' ')),2,1)
    x = 0
    line = 0
    loop do
      @text[x].each_index do |y|
        if @text[x][y] != ' '
          @body[line+1][y+2]=@text[x][y]
          render
          sleep(sleep_time)
        end
      end
      if x > 10 && x < @text.size - 12
        @cur_upper_line+=1
        r = @text[@cur_upper_line,line]
        r.push Array.new(62, ' ')
        add_block(r,2,1)
        render
      else
        line+=1
      end
      x+=1
      break if x == @text.size
    end
  end

  def move_text_line(direction)
    if @cur_upper_line + direction >= 0 && @cur_upper_line + direction <= @text.size-23
      @cur_upper_line += direction
      add_block(@text[@cur_upper_line,23],2,1)
    end
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
end
class Bar
  attr_reader :value
  def value=(v)
    if v > @max_value
      @value = @max_value
      return
    end
    if v < 0
      @value = 0
      return
    end
    @value = v
  end
  def initialize(name, max_value, value)
    @name = name
    @max_value = max_value
    @value = value
  end

  def to_s
    light = 20 - @value*20/@max_value
    up =
      "┏━━━━━━━━━━━━━━━━━━━┓\n"
    down =
      "┗━━━━━━━━━━━━━━━━━━━┛"
    if light > 0
      up[0]="┌"
      down[0]="└"
      (light-1).times do |i|
        up[i+1]="─"
        down[i+1]="─"
      end
      if light == 20
        up[light]="┐"
        down[light]="┘"
      else
        up[light]="┲"
        down[light]="┺"
      end
    end
    "%10s" % @name + up + "%10d" % @value.to_s + down
  end
end
