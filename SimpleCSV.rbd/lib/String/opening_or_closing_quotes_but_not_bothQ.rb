# String/opening_or_closing_quotes_but_not_both?
# String/opening_or_closing_quotes_but_not_bothQ

# 2010.05.19
# 0.0.0

# History: Taken from CSVFile/String.rb 0.8.2 (removed in 0.8.3)

require 'String/opening_or_closing_quotesQ'
require 'String/not_both_opening_and_closing_quotesQ'

class String
  
  def opening_or_closing_quotes_but_not_both?
    opening_or_closing_quotes? && not_both_opening_and_closing_quotes?
  end
  
end
