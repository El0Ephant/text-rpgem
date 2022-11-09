# frozen_string_literal: true

require_relative "version"

module TextRpgem
  class Error < StandardError; end
  
  require_relative 'scenario/scenario'
  require_relative 'scenario/event'
  require_relative 'scenario/counter'
  require_relative 'terminal_graphics/window'
end
