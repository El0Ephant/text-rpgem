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

end
