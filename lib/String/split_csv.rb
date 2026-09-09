# String/split_csv
# String#split_csv

# 20111110, 20260910
# 0.8.0

# History: Written for SimpleCSV.  

# Todo: 
# 1. Consider having a mode which splits up strings as if they were unquoted, but retains quotes (which contain commas) as per 0.4.0.  I think that is what I had in mind when I thought that the other two libraries weren't handling it correctly.  It should really be optional as to how quotes are handled.  

# Notes: 
# 1. I reckon both CSV and FasterCSV handle doubly-quoted quotes incorrectly.  If I am wanting everything between the commas, then that means *everything*, including any quote marks regardless of where they are.  If additionally, I am wanting to selectively choose only that which is between, then I can do this too by specifying that the data contained therein is mixed and so I dispense with the outer-most quote marks.  CSV and FasterCSV presume to know what I want and dispense with the outer quote marks even though the rest of a line is being parsed as if there are none.  This is inconsistent.  

# Changes since 0.6: 
# 1. + row_separator.  
# 0/1
# 2. ~ split_csv, the receiver is no longer chomped in place; trailing empty fields are kept; a doubled quote inside a quoted field reads as one; the separator is kept between the pieces of a quoted field; under :double a wholly quoted row splits on quote-separator-quote.

class String
  
  def split_csv(quote = nil, column_separator = ',', row_separator = nil)
    row = row_separator ? self.chomp(row_separator) : self.chomp
    case quote
    when :none, :unquoted
      row.split(column_separator, -1)
    when :double, :double_quoted, :double_quotes
      if row.start_with?('"')
        row.delete_prefix('"').delete_suffix('"').split('"' + column_separator + '"', -1).collect{|e| e.gsub('""', '"')}
      else
        row.split(column_separator, -1)
      end
    else
      split_row = []
      assembling_column = false
      buffer = +''
      row.split(column_separator, -1).each do |e|
        if assembling_column && !(e =~ /"$/) # e.not_closing_quotes?
          buffer << e << column_separator
        elsif assembling_column && e =~ /"$/ # e.closing_quotes?
          buffer << e.sub(/"$/, '') # remove the trailing quote
          split_row << buffer.gsub('""', '"')
          assembling_column = false
        elsif (e =~ /^"/) && (e.length == 1 || !(e =~ /"$/)) # e.opening_quotes_but_not_closing_quotes?
          buffer = +''
          buffer << e.sub(/^"/, '') << column_separator # remove leading quote and replace the column_separator
          assembling_column = true
        else
          if (e =~ /^"/) && (e =~ /"$/) # e.both_opening_and_closing_quotes? (a lone quote having been taken as opening above)
            split_row << e.sub(/^"/, '').sub(/"$/, '').gsub('""', '"')
          else
            split_row << e
          end
        end
      end
      split_row
    end
  end
  
end
