require 'Array/quote_each'

class Array
  
  def to_csv_spacey_unquoted
    self.join(', ')
  end
  
end
