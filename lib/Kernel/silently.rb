# Kernel/silently
# Kernel#silently

# 20111123
# 0.0.0

require 'Kernel/with_warning'

module Kernel
  
  def silently
    with_warning(0){ yield }
  end
  
end
