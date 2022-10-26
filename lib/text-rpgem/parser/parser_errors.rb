# frozen_string_literal: true

module Parser
  # Basic class for errors during parsing event files
  class ParsingError < StandardError
    attr_reader :file_name

    def initialize(msg, file_name)
      @msg = msg
      @file_name = file_name
      super msg
    end

    def to_s
      "#{@msg} in file #{@file_name}"
    end
  end
end
