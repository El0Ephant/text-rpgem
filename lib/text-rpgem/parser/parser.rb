# frozen_string_literal: true

require_relative "parser_errors"

# Module for parsing events from text files
module Parser
  module_function

  # The main method for parsing an event from a file
  # @param path [String] path to file
  # @return [Array] [ string description, hash of the form {'alias for option': 'option description'} ]
  def parse_event(path, encoding = "UTF-8")
    text = File.read(path, encoding: encoding)
    Validation.validate_global text, path

    description = /([^\\]|^){(?<text>(.|\s)*?[^\\])}/.match(text)
    Validation.validate_match_data_nil description, :Description, path
    description = description["text"]
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

      # raise ParsingError.new "Wrong option format", file_name unless options_block&.match(/[^\\]\[\]/).nil?
      # options_block&.scan(/([^\\]?)\[((.|\s)*?[^\\])\]/) do |option|
      #   Validation.validate_option option[1], file_name
      #   option_alias, option_desc = option[1]&.split "::"
      #   options[option_alias.strip] = option_desc.strip
      # end

      options_block&.strip!
      options_block&.split(/(?<=[^\\])\]\s*/) do |option|
        option = option[1..]
        Validation.validate_option option, file_name
        option_alias, option_desc = option&.split "::"
        options[option_alias.strip] = option_desc.strip
      end

    end
    options
  end

  # Module for validation parsing entities
  module Validation
    module_function

    def validate_global(text, file_name)
      # Checking for characters outside brackets
      if !text.match(/^\s*\S+\s*[^\\]{/).nil? || !text.match(/[^\\][}\]]\s*[^\s\[\]{}]+\s*[^\\]($|\[)/).nil?
        raise ParsingError.new "Characters outside brackets", file_name
      end
    end
    def validate_match_data_nil(match_data, block_name, file_name)
      raise ParsingError.new "Cannot find #{block_name}", file_name if match_data.nil?
    end
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

# puts Parser.parse_event "#{File.dirname(__FILE__ )}/1.txt"