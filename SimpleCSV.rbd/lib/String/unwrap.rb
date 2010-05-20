# String#unwrap

# 2010.05.19
# 0.0.0

class String
  
  def unwrap(wrapper)
    sub(/^#{wrapper}/, '').sub(/#{wrapper}$/, '')
  end
  
end
