# String#split_csv_mixed_quoted

# 2010.05.19
# 0.0.0

# History: Written for CSVFile 0.9.0.  

class String
  
  def split_csv_mixed_quoted
    split_row = []
    assembling_column = false
    simple_split.each do |e|
      if e.assembling_column && !e.closing_quotes?
        buffer << e
      elsif e.assembling_column && e.closing_quotes?
        buffer << e
        split_row << e
        assembling_column = false
      elsif e.opening_or_closing_quotes_but_not_both?
        buffer << e
        assembling_column = true
      else
        split_row << e
      end
    end
    split_row
  end
  
end
