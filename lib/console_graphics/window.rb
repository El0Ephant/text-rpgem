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
    system 'cls'
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

