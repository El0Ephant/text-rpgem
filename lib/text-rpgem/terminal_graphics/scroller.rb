class Scroller
  attr_accessor :count,:line,:pos,:sz,:last, :body # fields

  def initialize (count) # constructor
    @count = count # count of strings
    @sz = 23 # size
    k = 1 # movement
    t = 1 # fixer
    step = 0.2
    @line = [1] * sz # scroller
    @body = [0] * count
    while count > sz * t
      t += step
      @line[sz-k] = 0
      k+=1
      if @sz * t > 100
        step +=1
      end
      if @sz * t > 300
        break
      end
      if  count > 1000
        @line[1] = 0
      end
    end
    @last = 0
    (0..@line.length - 1).each { |i|
      @body[i] = @line[i]
      if @body[i] == 1
        @last = i
      end
    }
    @pos = 0
  end
  def move_down
    if @count > @sz
      @pos += 1
      @body[pos-1] = 0
      @body[pos+last] = 1

    end
  end
  def move_up
    if @count > @sz
      @pos -= 1
      @body[pos] = 1
      @body[pos+last+1] = 0
    end
  end

  end
 s = Scroller.new(80)

count = s.count
str = "text                             "

s.move_down()
s.move_down()
s.move_up()

arr = s.body
(0..count - 1).each { |i|
  if arr[i] == 1
    puts(str + "█\n")
  end
  if arr[i] == 0
    puts(str + " \n")
  end
}

