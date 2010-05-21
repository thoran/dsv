# String#split_csv

# 2010.05.22
# 0.2.0

# History: Originally written for CSVFile 0.9.0.  This one for 0.9.2.  

# Changes: 
# 1. It actually works for doing mixed quoted strings now.  

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
      buffer = ''
      self.split(/,/).each do |e|
        if assembling_column && !e.closing_quotes?
          buffer << e
        elsif assembling_column && e.closing_quotes?
          buffer << e
          split_row << buffer
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
