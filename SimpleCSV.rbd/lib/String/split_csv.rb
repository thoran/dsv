# String#split_csv

# 2011.02.17
# 0.6.0

# History: Originally written for SimpleCSV 0.9.0.  This too is for SimpleCSV 0.9.6.  

# Todo: 
# 1. Consider having a mode which splits up strings as if they were unquoted, but retains quotes (which contain commas) as per 0.4.0.  I think that is what I had in mind when I thought that the other two libraries weren't handling it correctly.  It should really be optional as to how quotes are handled.  

# Notes: 
# 1. I reckon both CSV and FasterCSV handle doubly-quoted quotes incorrectly.  If I am wanting everything between the commas, then that means *everything*, including any quote marks regardless of where they are.  If additionally, I am wanting to selectively choose only that which is between, then I can do this too by specifying that the data contained therein is mixed and so I dispense with the outer-most quote marks.  CSV and FasterCSV presume to know what I want and dispense with the outer quote marks even though the rest of a line is being parsed as if there are none.  This is inconsistent.  

# Changes since 0.5: 
# 1. + column_separator.  

class String
  
  def split_csv(quote = nil, column_separator = ',')
    case quote
    when :none, :unquoted
      self.chomp.split(column_separator)
    when :double, :double_quoted, :double_quotes
      self.chomp.split(column_separator).collect{|e| e.sub(/^"/, '').sub(/"$/, '')}
    else
      split_row = []
      assembling_column = false
      buffer = ''
      self.chomp!
      self.split(column_separator).each do |e|
        if assembling_column && !(e =~ /"$/) # e.not_closing_quotes?
          buffer << e
        elsif assembling_column && e =~ /"$/ # e.closing_quotes?
          buffer << e.sub(/"$/, '') # remove the trailing quote
          split_row << buffer
          assembling_column = false
        elsif (e =~ /^"/) && !(e =~ /"$/) # e.opening_quotes_but_not_closing_quotes?
          buffer = ''
          buffer << e.sub(/^"/, '') + column_separator # remove leading quote and replace the column_separator
          assembling_column = true
        else
          if (e =~ /^"/) && (e =~ /"$/) # e.both_opening_and_closing_quotes?
            split_row << e.sub(/^"/, '').sub(/"$/, '')
          else
            split_row << e
          end
        end
      end
      split_row
    end
  end
  
end
