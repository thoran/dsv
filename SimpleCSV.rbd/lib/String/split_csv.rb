# String#split_csv

# 2010.05.19
# 0.1.0

# History: Originally written for CSVFile 0.9.0.  This one for 0.9.1.  

# Changes: 
# 1. Now doing the quoting directly, since calling split_csv_* all the time is lots of extra method calls.  

class String
  
  def split_csv(quote = nil)
    case quote
    when :none, :unquoted
      self.chomp.split(/,/)
    when :double, :double_quoted, :double_quotes
      self.chomp.split(/,/).collect{|e| e.sub(/^"/, '').sub(/"$/, '')}
    else
      split_row = []
      assembling_column = false
      self.chomp.split(/,/).each do |e|
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
  
end
