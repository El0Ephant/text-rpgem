# Module for using escape characters in the console
module EscapeChars
  module_function

  def hide_cursor
    print "\e[?25l"
  end

  def exit_app
    print "\e[H\e[2j"
  end

  def move_cursor_to(x: 1, y: 1)
    print "\e[#{x};#{y}H"
  end

  def highlight_text
    print "\e[7m"
  end

  def normalize_text
    print "\e[27m"
  end
end