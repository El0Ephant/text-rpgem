module Parser
  module_function

  # The main method for parsing an event from a file
  # @param path [String] path to file
  # @return [Array] first value - string description, second - hash of the form {'alias for option': 'option description'}
  def parse_event(path)
    path = File.dirname(__FILE__ ) + '/' + path
    text = File.read(path)

    description = text[/(?<={)(.|\s)*(?=})/]
    Validation.validate_description description
    description&.strip!

    options_block = text[/\[(.|\s)*\]/]
    Validation.validate_options_block options_block
    options = get_options_hash options_block
    [description, options]
  end

  # A method for transform options block
  # @param options_block [String,nil] lines with options description from file
  # @return [Hash] hash of the form {'alias for option': 'option description'}
  def get_options_hash(options_block)
    options = {}
    if options_block.nil?
      return options
    end
    options_block&.scan(/\[((.|\s)*?)\]/) {|option|
      Validation::validate_option option
      option_alias, option_desc = option[0]&.split '::'
      options[option_alias] = option_desc
    }
    options
  end

  module Validation
    module_function

    def validate_description(description)
      #TODO
    end

    def validate_options_block(options_block)
      #TODO
    end

    def validate_option(option)
      #TODO
    end
  end

end

