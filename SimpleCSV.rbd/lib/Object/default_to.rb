# Object/default_to.rb
# Object#default_to

# 20140524
# 0.2.0

# Description: Enables a slightly more powerful assignment mechanism than does ||=, such that it will assign a default value to a variable if the parameterized source is nil, whereas ||= will only assign to the paramterized source if the variable is not already set.

# History: Taken from Switches 0.9.9.

# Changes:
# 1. - alias_method :default, since it was clashing with the ruby mail gem.
# 2. + require 'NilClass/default_to', since these two are supposed to work together.

require 'NilClass/default_to'

class Object

  def default_to(o)
    self
  end
  alias_method :defaults_to, :default_to
  alias_method :default_is, :default_to

end
