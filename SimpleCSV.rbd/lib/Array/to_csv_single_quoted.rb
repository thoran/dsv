require 'Array/quote_each'

class Array
  
  def to_csv_single_quoted
    self.quote_each("'").join(',')
  end
  
end
