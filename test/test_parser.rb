require 'test/unit'
require_relative  '../lib/text-rpgem/parser/parser'
require_relative '../lib/text-rpgem/parser/parser_errors'

class ParserTest < Test::Unit::TestCase
  def test_parse_event_default
    assert_equal(["great description",
                  {"option1"=>"go left", "option2"=>"go straight", "option3"=>"go right"}],
                 Parser.parse_event("#{File.dirname(__FILE__)}/DemoMarkup.txt"))
  end
  def test_parse_event_one_word
    assert_equal(["text", {"option1"=>"go left"}],
                 Parser.parse_event("#{File.dirname(__FILE__)}/oneword.txt"))
  end
  def test_empty_description
    assert_raises Parser::ParsingError do
      Parser.parse_event("#{File.dirname(__FILE__)}/null_desc.txt")
    end
  end
  def test_empty_file
    assert_raises Parser::ParsingError do
      Parser.parse_event("#{File.dirname(__FILE__)}/empty.txt")
    end
  end
  def test_extra_brackets
    assert_raises Parser::ParsingError do
      Parser.parse_event("#{File.dirname(__FILE__)}/extra_brackets.txt")
    end
  end
  def test_wrong_options
    assert_raises Parser::ParsingError do
      Parser.parse_event("#{File.dirname(__FILE__)}/wrong_options.txt")
    end
  end
  def test_empty_brackets
    assert_raises Parser::ParsingError do
      Parser.parse_event("#{File.dirname(__FILE__)}/empty_brackets.txt")
    end
  end

end