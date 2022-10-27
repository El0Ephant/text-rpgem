# frozen_string_literal: false

# Scroller class
class Scroller
  attr_reader :result_arr

  def initialize(length)
    @length = length
    @position = 0
    @result_arr = Array.new(23) { [" "] }
    @scroller_length = [(23.0 / (length + 1) * 23).ceil, 23].min
    @scroller_length&.times do |i|
      @result_arr[i][0] = "█"
    end
  end

  def move(direction)
    if (@position * 23 / @length) != ((@position + direction) * 23 / @length)
      if direction.negative?
        @result_arr.rotate! 1
      else
        @result_arr.rotate!(-1)
      end
    end
    @position += direction
  end

end
