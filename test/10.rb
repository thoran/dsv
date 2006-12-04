# Test CSVFile

# 20070104
# 0.5.10 (skipped 7-9)

# Changes since 0.4: 
# 1. Nothing significant so far...  Just doing some refactoring.  
# 2. Just doing reads so as to optimise this some for speed.  
# 3/4
# 3. Testing the new #new interface.  
# 4/5
# 4. Testing the changes to #read mostly, since the other changes are to writing, but which were tested when doing the call log stuff.  
# 5/6
# 5. Checking a few changes, but mostly the changes in String#csv_split.  
# 6/10
# 6. 

@debug = true
require 'pp' if @debug
@profile = true
require 'profile' if @profile

require '../lib/csv_file'

in_filename = 'test.csv'
in_file = CSVFile.readlines(in_filename)
pp in_file
