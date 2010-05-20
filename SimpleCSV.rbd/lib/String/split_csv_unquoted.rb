# String#split_csv_unquoted

# 2010.05.19
# 0.0.0

# History: Written for CSVFile 0.9.0.  

class String
  
  def split_csv_unquoted
    self.chomp.split(/,/)
  end
  
end
