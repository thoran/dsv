# String/not_both_opening_and_closing_quotes?
# String/not_both_opening_and_closing_quotesQ

# 2010.05.19
# 0.0.0

# History: Taken from CSVFile/String.rb 0.8.2 (removed in 0.8.3)

require 'String/opening_and_closing_quotesQ'

class String
  
  def not_both_opening_and_closing_quotes?
    !opening_and_closing_quotes?
  end
  
end
