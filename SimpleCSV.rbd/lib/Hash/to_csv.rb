# Hash/to_csv

# 2010.05.18, 19, 20
# 0.9.0

# Changes: 
# 1. - Hash#write.  
# 2. ~ Hash#to_csv, a significant reduction in complexity.  

# Todo: 
# 1. Split all these up and move each method into Array...  Done as of 0.9.0.  
# 2. Tidy the splat stuff with that technique from recently!?...  Done/made redundant as of 0.9.0.  

require 'Array/extract_optionsX'
require 'Array/to_csv'

class Hash
  
  def to_csv(*args)
    options = args.extract_options!
    quote = options[:quote]
    desired_columns = options[:desired_columns]
    collector = []
    if desired_columns
      desired_columns.each{|column| collector << self[column]}
    else
      self.each{|k,v| collector << self[v]}
    end
    collector.to_csv(quote)
  end
  
end
