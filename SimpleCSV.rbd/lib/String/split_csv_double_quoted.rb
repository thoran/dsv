# String#split_csv_double_quoted

# 2010.05.20
# 0.0.1

# History: Written for CSVFile 0.9.0.  

# Changes: 
# 1. + require 'String/unwrap'.  

require 'String/unwrap'

class String
  
  def split_csv_double_quoted
    self.chomp.split(/,/).collect{|e| e.unwrap('"')}
  end
  
end
