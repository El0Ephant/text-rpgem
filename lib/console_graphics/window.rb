class Window
  attr_reader :width, :height
  def initialize(w, h)
    @body = Array.new(h) {Array.new(w)}
    @width = w
    @height = h
    h.times do |i|
      w.times do |j|
        @body[i][j]='╳'
      end
    end
    system 'cls'
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

  def win_print
    return_size
    print "\e[1;1H"
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
end

# @perc = 0
# t = Thread.new { loop do ; @perc += 1 ; sleep 0.050 ; end }
# until @perc == 100
#   puts "Downloading: (" + @perc.to_s + "%)"
#   print "\r\e[A"
#   #sleep 0.050
# end
# t.kill
# puts "Downloading: (100%)"
# print "\r\e[A"
