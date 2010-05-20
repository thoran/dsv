# Array#quote_each

# 2010.05.19
# 0.0.0

require 'Array/wrap_each'

class Array
  
  def quote_each(mark = '"')
    wrap_each(mark)
  end
  
end
