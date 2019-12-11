# NilClass/default_to.rb
# NilClass#default_to

# 20140524
# 0.2.0

# Description: Used in concert with Object#default_to, NilClass#default_to will assign a default value to a variable if that variable is nil, or if it isn't nil Object#default_to will return the value of the variable already set.  

# History: Taken from Switches 0.9.9.

# Changes:
# 1. - alias_method :default, since the complement, Object#default_to, was clashing with the ruby mail gem.
# 2. + require 'Object/default_to', since these two are supposed to work together.

require 'Object/default_to'

class NilClass

  def default_to(o)
    o
  end
  alias_method :defaults_to, :default_to
  alias_method :default_is, :default_to

end
