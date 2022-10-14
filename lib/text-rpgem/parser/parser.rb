# frozen_string_literal: true

require_relative "parser_errors"

# Module for parsing events from text files
module Parser
  module_function

  # The main method for parsing an event from a file
  # @param path [String] path to file
  # @return [Array] [ string description, hash of the form {'alias for option': 'option description'} ]
  def parse_event(path)
    text = File.read(path)

    description = text[/(?<={)(.|\s)*?(?=[^\\]})/]
    Validation.validate_emptiness description, :Description, path
    Validation.validate_extra_brackets description, :Description, path
    description&.strip!

    options_block = text[/[^\\]\[(.|\s)*[^\\]\]/]
    options = get_options_hash options_block, path
    [description, options]
  end

  # A method for transform options block
  # @param options_block [String,nil] lines with options description from file
  # @return [Hash] hash of the form {'alias for option': 'option description'}
  def get_options_hash(options_block, file_name)
    options = {}
    unless options_block.nil? || !options_block&.match(/\A\s*\z/).nil?
      options_block&.scan(/[^\\]?\[((.|\s)*?[^\\])\]/) do |option|
        Validation.validate_option option[0], file_name
        option_alias, option_desc = option[0]&.split "::"
        options[option_alias.strip] = option_desc.strip
      end
    end
    options
  end

  # Module for validation parsing entities
  module Validation
    module_function

    def validate_emptiness(block, block_name, file_name)
      raise ParsingError.new "Empty #{block_name}", file_name if block.nil? || !block.match(/\A\s*\z/).nil?
    end

    def validate_extra_brackets(block, block_name, file_name)
      raise ParsingError.new "#{block_name} includes extra brackets", file_name unless block.match(/[^\\][{}\[\]]/).nil?
    end

    def validate_option(option, file_name)
      raise ParsingError.new "Wrong option format", file_name if option.scan("::").count != 1

      option_alias, option_desc = option.split "::"
      validate_emptiness option_alias, :OptionAlias, file_name
      validate_extra_brackets option_alias, :OptionAlias, file_name
      validate_emptiness option_desc, :OptionDescription, file_name
      validate_extra_brackets option_desc, :OptionDescription, file_name
    end
  end
end
