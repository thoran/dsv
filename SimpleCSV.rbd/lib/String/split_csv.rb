# String#split_csv

# 2010.05.26
# 0.4.0

# History: Originally written for SimpleCSV 0.9.0.  This one is for 0.9.3.  

# Changes since 0.3: 
# 1. ~ String#split_csv, so that it now handles doubly-quoted double quotes correctly; though it could probably be more generic than this.  

# Notes: 
# 1. I reckon both CSV and FasterCSV handle doubly-quoted quotes incorrectly.  If I am wanting everything between the commas, then that means *everything*, including any quote marks regardless of where they are.  If additionally, I am wanting to selectively choose only that which is between, then I can do this too by specifying that the data contained therein is mixed and so I dispense with the outer-most quote marks.  CSV and FasterCSV presume to know what I want and dispense with the outer quote marks even though the rest of a line is being parsed as if there are none.  This is inconsistent.  

class String
  
  def split_csv(quote = nil)
    case quote
    when :none, :unquoted
      self.chomp.split(',')
    when :double, :double_quoted, :double_quotes
      self.chomp.split(',').collect{|e| e.sub(/^"/, '').sub(/"$/, '')}
    else
      split_row = []
      assembling_column = false
      buffer = ''
      self.chomp!
      self.split(',').each do |e|
        if assembling_column && !(e =~ /"$/) # e.not_closing_quotes?
          buffer << e
        elsif assembling_column && e =~ /"$/ # e.closing_quotes?
          buffer << e
          split_row << buffer
          assembling_column = false
        elsif ((e =~ /^"/) || (e =~ /"$/)) && !((e =~ /^"/) && (e =~ /"$/)) # e.opening_or_closing_quotes_but_not_both?
          buffer << e
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
