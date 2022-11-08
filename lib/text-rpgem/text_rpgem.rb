# frozen_string_literal: true

require_relative "version"

module TextRpgem
  class Error < StandardError; end

  require_relative 'parser/parser'
  require_relative 'parser/parser_errors'
  require_relative 'scenario/scenario'
  require_relative 'scenario/event'
  require_relative 'scenario/counter'
  require_relative 'terminal_graphics/terminal_graphics'
end
