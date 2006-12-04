#!/usr/bin/env ruby
# diffile

# 20070109
# 0.2.8

# History: When optimising CSVFile, I realised that it would be good to compare the output of the Ruby profiler from one run with another run.  

# Goals for 0.2: 
# 1. Implement sorting.  
# 2. Implement comparison.  

# Changes since 0.0: 
# 1. Created ProfileOutput::@profile and removed #parse::lines.  
# 2. Made the results of the parse instance variables and made a small change to the name.  
# 3. Re-introduced the (now even even more) heavily-modified stuff from svnimportall.  
# 4. Created a list of method names for each of the two profiles.  
# 5. /comparison/differences/.  
# 6. Finished the determination of which methods are added, deleted, and which ones are neither.  
# 7. Started on the code to do the differences but realised that because I can't access the list of methods by name without iterating through them, that I should consider redoing the ProfileOutput#parse code to be a hash instead of an array.  Either way, I thought I stop here since there's a few things to be looked at already.  
# 0/1
# 8. It is sorting stupidly: 5.56 > 29.17!  Added #to_i to the comparisons to using #to_i.  I'll need to ensure that this will select whether to use #to_i or not, depending on whether the field by which it is to be compared is reasonably to be represented as a number.  
# 1/2
# 9. Removed the field argument from Diffile as it isn't presently needed at least.  
# 10. Working otherwise.  
# 2/3
# 11. I've decided I don't especially need to know which methods have been added, deleted, or remained in place, since I can just do the arithmetic anyways.  So, I've moved each of the different lists of methods into their own methods #additions, #deletions, and #unchanged (rather than #static, since that implies something else in respect of methods.)  
# 12. Moved profile_names (1 and 2) up to #init and made them instance variables.  
# 13. That's working.  
# 3/4
# 14. For now, in #compare, I've decided to iterate through both sets of profiles inspite of this being pretty inefficient.  
# 15. #compare doesn't cope with added and deleted methods, since the names must match before a difference will be calculated...  I'll need to make an separate and explicit list for additions and deletions as per I was going to do but decided I didn't need to do!  
# 16. It isn't crashing, but it doesn't seem to be doing much of use either.  
# 4/5
# 17. Added a test so that something will be inserted into the difference hash will only if the current method name matches the outer loop name.  I'm wondering if this will work...  
# 18. Removed the conditional for creating the differences hash entry, since it should only need to be created once and therefore does not need to check as to whether it exists or not, but merely be created.  
# 19. And making it an array is redundant, so it is merely an assignment now too.  
# 20. Working, but could be faster methinks.  
# 5/6
# 21. ProfileOutput#parse now supplies @profile as a hash of hashes.  
# 22. Added Array#hcae to assist with ProfileOutput#parse.  
# 23. Modified Diffile#compare to use the new @profile and as anticipated it is much simpler and probably a lot faster too.  
# 24. The assembling of @profile_n_names needs to change.  Done.  
# 25. There is a problem with ProfileOutput#parse which causes the key not to be loaded into @profile.  Working now.  
# 6/7
# 26. Removed debugging from ProfileOutput#parse.  
# 27. Diffile#compare is working properly with the new @profile(s) now.  
# 7/8
# 28. Stopped the 'cumulative_seconds' column from being put into differences, since there is no order.  
# 29. The number of calls in #compare is no longer converted to floats.  

require 'pp'

class Array
  
  def hcae
    self.reverse.each {|e| yield e}
  end
  alias_method :reverse_each, :hcae
  
end


class ProfileOutput
  
  attr_reader :columns
  
  def initialize
    @columns = %w(percentage_time cumulative_seconds self_seconds calls self_milliseconds_per_call total_milliseconds_per_call name)
    @profile = {}
  end
  
  def parse(captured_output)
    line_count = -1
    captured_output.each do |line|
      line_count += 1
      if line_count > 1
        column_count = 7
        key = ''
        line.split.hcae do |column|
          column_count -= 1
          if column_count == 6
            key = column
            @profile[key] = {}
          else
            @profile[key][@columns[column_count]] = column
          end # if
        end # line.split.hcae
      end # if
    end # captured_output.each
    @profile
  end
  
end # class ProfileOutput

class Diffile
  
  def initialize
    first_program = ARGV[0]
    second_program = ARGV[1]
    @profile_1 = ProfileOutput.new.parse(`ruby -r 'profile' #{first_program} 2>&1`)
    @profile_2 = ProfileOutput.new.parse(`ruby -r 'profile' #{second_program} 2>&1`)
    @profile_1_names = (a = []; @profile_1.each{|k,v| a << k}; a)
    @profile_2_names = (a = []; @profile_2.each{|k,v| a << k}; a)
  end
  
  def sort_by(field)
    pp @profile_1.sort!{|a,b| a[field.to_s].to_i <=> b[field.to_s].to_i}
    pp @profile_2.sort!{|a,b| a[field.to_s].to_i <=> b[field.to_s].to_i}
  end
  
  def deletions
    deletions = []
    @profile_1_names.each do |profile_1_name|
      unless @profile_2_names.include?(profile_1_name)
        deletions << profile_1_name
      end
    end
    deletions
  end # def deletions
  
  def additions
    additions = []
    @profile_2_names.each do |profile_2_name|
      unless @profile_1_names.include?(profile_2_name)
        additions << profile_2_name
      end
    end
    additions
  end # def additions
  
  def unchanged
    unchanged = []
    @profile_2_names.each do |profile_2_name|
      if @profile_1_names.include?(profile_2_name)
        unchanged << profile_2_name
      end
    end
    unchanged
  end # def unchanged
  
  def compare
    differences = {}
    columns = ProfileOutput.new.columns
    all_names = @profile_1_names | @profile_2_names
    all_names.each do |name|
      #pp name # debug
      difference = {}
      columns.each do |column|
        if !(column == 'name' || column == 'cumulative_seconds')
          if column == 'calls'
            difference[column] = @profile_2[name][column].to_i - @profile_1[name][column].to_i
          else
            difference[column] = @profile_2[name][column].to_f - @profile_1[name][column].to_f
          end # if
        end # if
      end # columns.each
      differences[name] = difference
    end # all_names.each
    differences
  end # def compare
  
end # class Diffile

if __FILE__ == $0
  diffile = Diffile.new
  #diffile.sort_by('percentage_time')
  pp diffile.compare
end
