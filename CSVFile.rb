# File/CSVFile

# 2010.03.25
# 0.8.1

# Description: This loads all the different class files associated with making CSVFile work.  

# Changes: 
# 0/1
# 1. Changed the version number above to reflect the overall CSVFile version number.  

require 'File/relative_path'

require File.relative_path('CSVFile/CSVFile.rb')

require File.relative_path('CSVFile/lib/Array.rb')
require File.relative_path('CSVFile/lib/Hash.rb')
require File.relative_path('CSVFile/lib/Index.rb')
require File.relative_path('CSVFile/lib/String.rb')
