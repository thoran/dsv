# String#wrap

# 2010.05.19
# 0.0.0

class String
  
  def wrap(wrapper)
    wrapper + self + wrapper
  end
  
end
