require 'Array/quote_each'

class Array
  
  def to_csv_spacey_double_quoted
    self.quote_each('"').join(', ')
  end
  
end
