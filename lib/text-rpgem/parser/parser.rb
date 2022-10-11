# frozen_string_literal: true

# Module for parsing events from text files
module Parser
  module_function

  # The main method for parsing an event from a file
  # @param path [String] path to file
  # @return [Array] [ string description, hash of the form {'alias for option': 'option description'} ]
  def parse_event(path)
    text = File.read(path)

    description = text[/(?<={)(.|\s)*?(?=[^\\]})/]
    Validation.validate_emptiness description, "Description"
    Validation.validate_extra_brackets description, "Description"
    description&.strip!

    options_block = text[/[^\\]\[(.|\s)*[^\\]\]/]
    Validation.validate_emptiness options_block, "OptionsBlock"
    options = get_options_hash options_block
    [description, options]
  end

  # A method for transform options block
  # @param options_block [String,nil] lines with options description from file
  # @return [Hash] hash of the form {'alias for option': 'option description'}
  def get_options_hash(options_block)
    options = {}

    options_block&.scan(/[^\\]\[((.|\s)*?)[^\\]\]/) do |option|
      Validation.validate_option option[0]
      option_alias, option_desc = option[0]&.split "::"
      options[option_alias] = option_desc
    end
    options
  end

  # Module for validation parsing entities
  module Validation
    module_function

    def validate_emptiness(block, block_name)
      if block.nil? || block.empty? || !block.match(/\A\s*\z/).nil?
        raise "Empty#{block_name}" # TODO: Exception
      end
    end

    def validate_extra_brackets(block, block_name)
      raise "#{block_name}IncludeExtraBrackets" unless block.match(/[^\\][{}\[\]]/).nil? # TODO: Exception
    end

    def validate_option(option)
      raise "WrongOptionFormat" unless option.include? "::" # TODO: Exception

      option_alias, option_desc = option.split "::"
      validate_emptiness option_alias, :OptionAlias
      validate_extra_brackets option_alias, :OptionAlias
      validate_emptiness option_desc, :OptionDescription
      validate_extra_brackets option_desc, :OptionDescription
    end
  end
end

