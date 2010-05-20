# Array#wrap_each

# 2010.05.19
# 0.0.0

require 'String/wrap'

class Array
  
  def wrap_each(wrapper)
    collect{|e| e.wrap(wrapper)}
  end
  
end
