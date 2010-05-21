# String/opening_and_closing_quotes?
# String/opening_and_closing_quotesQ

# 2010.05.19
# 0.0.0

# History: Taken from CSVFile/String.rb 0.8.2 (removed in 0.8.3)

require 'String/opening_quoteQ'
require 'String/closing_quoteQ'

class String
  
  def opening_and_closing_quotes?
    opening_quote? && closing_quote?
  end
  
end
