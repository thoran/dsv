# String/closing_quote?
# String/closing_quoteQ

# 2010.05.19
# 0.0.0

# History: Taken from CSVFile/String.rb 0.8.2 (removed in 0.8.3)

class String
  
  def closing_quote?
    (self =~ /"$/) ? true : false
  end
  alias_method :closing_quotes?, :closing_quote?
  
end
