require 'test/unit'
require 'lib/text-rpgem/parser/parser.rb'

class ParserTest < Test::Unit::TestCase
  def test_parse_event_1
    assert_equal(["great description",
                  {"option1"=>"go left", "option2"=>"go straight", "option3"=>"go right"}],
                 Parser.parse_event("#{File.dirname(__FILE__)}/DemoMarkup.txt"))
  end
end