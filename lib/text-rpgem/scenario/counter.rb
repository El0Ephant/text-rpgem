# frozen_string_literal: true

class Counter
  # @param [Integer] value
  def initialize(value)
    @value = value
  end
  attr_accessor :value
end

class Bar < Counter
  def initialize(value, max, min)
    @max = max
    @min = min
    super(value)
  end

  attr_reader :max, :min

  def value=(new_val)
    super(new_val) if min < new_val && new_val < max
  end

end
