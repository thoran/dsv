# Array/to_csv

# 2010.05.18, 19
# 0.9.0

# Changes: 
# 1. Has it's own file now.  

# Todo: 
# 1. Split all these up and move each method into Array...  Done as of 0.9.0.  
# 2. ~ Array#to_csv, massive refactor, including getting rid of a lot of aliases for now at least.  Done as of 0.9.0.  

require 'Array/to_csv_double_quoted'
require 'Array/to_csv_spacey_double_quoted'
require 'Array/to_csv_single_quoted'
require 'Array/to_csv_spacey_single_quoted'
require 'Array/to_csv_unquoted'
require 'Array/to_csv_spacey_unquoted'

class Array
  
  def to_csv(quote = :double)
    case quote.to_sym
    when :double; to_csv_double_quoted
    when :spacey_double; to_csv_spacey_double_quoted
    when :single; to_csv_single_quoted
    when :spacey_single; to_csv_spacey_single_quoted
    when :none, :unquoted; to_csv_unquoted
    when :spacey_none, :spacey_unquoted; to_csv_spacey_unquoted
    end
  end
  
end
