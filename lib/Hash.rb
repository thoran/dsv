# Hash.rb

# 20090104, 05
# 0.6.1

# Changes: 
# 1. Moved from same file as CSVFile.  

class Hash
  
  def write(file, *desired_columns) # Passing in the file_handle is a horrible kludge.  Should I subclass Hash for a CSVLine object?  That still doesn't guarantee access to the file object though, since I'd need to attach some reference to it to every line object.  It would be better if because of the context of a block that this message could be trapped and redirected somehow.  
    @file = file
    case desired_columns[0] # If I don't check for this, then by the time to_csv is called it might be possible that the atomic bits are two levels deep.  
      when Array
        file.puts(self.to_csv(desired_columns[0]))
      else
        file.puts(self.to_csv(desired_columns))
    end # case
  end # def write
  alias_method :write_line, :write
  alias_method :writeline, :write
  alias_method :writeln, :write
  
  def to_csv(*desired_columns)
    collector = []
    case desired_columns[0]
      when Array
        if desired_columns[0]
          desired_columns[0].each do |c| # Here is where re-ordering happens.  
            collector << self[c]
          end
        elsif @file.columns?
          file.columns.each do |k, v|
            collector << self[v]
          end
        else
          each do |k, v| # Assuming that the keys remain the same for each line, this should produce the same ordering of columns, but not the same as that entered...  
            collector << self[v]
          end
        end
      else
        if desired_columns
          desired_columns.each do |c|
            collector << self[c]
          end
        elsif @file.columns?
          file.columns.each do |k, v|
            collector << self[v]
          end
        else
          each do |k, v|
            collector << self[v]
          end
        end
    end # case
    pp collector if $debug
    collector.to_csv(@quote)
  end # def to_csv
  
end # class Hash
