# frozen_string_literal: true

class Counter
  # @param [Integer] value
  def initialize(value)
    @value = value
  end

  attr_accessor :value

end

class Bar < Counter
  def initialize(value, max, min: 0)
    @max = max
    @min = min
    super(value)
  end

  attr_reader :max, :min

  def value=(val)
    if val > @max
      @value = @max
      return
    end
    if val < @min
      @value = @min
      return
    end
    @value = val
  end


end
