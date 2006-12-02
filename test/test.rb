# Test CSVFile

# 20061203
# 0.4.7

# Changes since 0.3: 
# 1. Commented out the sorting stuff.  
# 2. Added in a direct reference to the csv_file for the iterator using the new interface on #each.  
# 0/1
# 3. Swapped to using #each_with_columns.  
# 1/2
# 4. Fixed a reference to line which shouldn't have been there.  
# 5. Now using the new on-the-fly block parameters for CSVFile's new method #each_with_columns.  
# 2/3
# 6. Moved output_filename up near the version number for reasons as best stated there.  
# 3/4
# 7. Checked to see if #read would handle symbols and it does by virtue of a column.to_s in #parse_line.  
# 8. Now checking to see if #each will handle symbols (I think it won't and I think I know why...)  And it did!  
# 9.  However, one has to be consistent.  I can't mix'n'match strings and symbols.  
# 4/5
# 10. Removed a lot of the commented out stuff.  
# 11. Testing writability of CSVFile.  
# 12. Changed everything from input and output to simply in and out.  
# 12. Removed the parameters from the in_file.each call.  
# 13. I'm using write_line on the out_file and the list of columns instead now.  
# 14. Switched to using CSVFile.new with the new interface for the outfile.  
# 15.  Added :double into the out_file object creation so as to tell an output file what to do with the lines!  
# 5/6
# 16. Replaced the loop and #write_line to test #write(_csv).  
# 17. Realised that I need to load the in_file value for lines into the out_file.  
# 18. I forgot to read the in_file.  Should I consider making the lines method explicit and call read from there?  
# 6/6.1 (No changes in lib file.)  
# 19. Testing that (re-)ordering is working OK.  
# 6.1/6.2
# 20. Testing that reading a writing to the same file is working OK.  It worked sort-of.  It appended to the file, which I understand would be because the lineno had not been reset...  
# 6.2/6.3
# 21. Seeing if I can get it over-write the file, rather than append.  This truncates first!  So, empty file!  
# 6.3/6.4
# 22. This is looking very much like 0.6.0 and 0.6.1, insofar as doing the lines = lines bit...  That worked, but it wasn't quite what I was after.  Perhaps anything other than 'r+' will not have the file rewound, but when 'r+' is the mode, that at the end of #read, then the file is rewound.  
# 6.4/7
# 23. I've made a small change to CSVFile#read, whereby it rewinds as the last thing that it does before returning @lines if the mode is set to 'r+'...  Hopefully now it will over-write...  It does, but doesn't get rid of what is already there!  
# 24. I've made another small change to CSVFile#read (truncate(0)), so now it works.  

#@debug = true
@debug = false

require 'pp' if @debug
require '../lib/csv_file'

in_filename = '7.csv'

in_file = CSVFile.new(in_filename, true, :double, 'r+')
in_file.read
in_file.write_csv('name', 'phone')
in_file.close
