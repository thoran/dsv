# Test CSVFile

# 20061206
# 0.5.5

# Changes since 0.4: 
# 1. Nothing significant so far...  Just doing some refactoring.  
# 2. Just doing reads so as to optimise this some for speed.  
# 3/4
# 3. Testing the new #new interface.  
# 4/5
# 4. Testing the changes to #read mostly, since the other changes are to writing, but which were tested when doing the call log stuff.  

@debug = false
require 'pp' if @debug
@profile = true
require 'profile' if @profile

require '../lib/csv_file'

in_filename = '5.csv'
in_file = CSVFile.new(in_filename, :header_line, :double_quotes, :read_only)
in_file.read
