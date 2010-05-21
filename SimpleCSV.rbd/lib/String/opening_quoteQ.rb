# String/opening_quote?
# String/opening_quoteQ

# 2010.05.19
# 0.0.0

# History: Taken from CSVFile/String.rb 0.8.2 (removed in 0.8.3)

class String
  
  def opening_quote?
    (self =~ /^"/) ? true : false
  end
  alias_method :opening_quotes?, :opening_quote?
  
end
