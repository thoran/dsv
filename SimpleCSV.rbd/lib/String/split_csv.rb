# String#split_csv

# 2010.05.19
# 0.0.0

# History: Written for CSVFile 0.9.0.  

require 'String/split_csv_unquoted'
require 'String/split_csv_double_quoted'
require 'String/split_csv_mixed_quoted'

class String
  
  def split_csv(quote = nil)
    case quote
    when :none, :unquoted; split_csv_unquoted
    when :double; split_csv_double_quoted
    when :mixed; split_csv_mixed_quoted
    else; split_csv_mixed_quoted
    end
  end
  
end
