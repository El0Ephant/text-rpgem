# frozen_string_literal: true

class Counter
  # @param [Integer] value
  def initialize(name, value)
    @value = value
    @name = name
  end

  attr_accessor :value
  attr_reader :name

end

class Bar < Counter
  def initialize(name, value, max, min: 0)
    @max = max
    @min = min
    super(name, value)
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
