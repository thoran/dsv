[thoran@thorans-macbook-2 ~/lib/ruby/SimpleCSV.rbd/lib/String]$ irb
require >> require 'split_csv.rb'
=> true
>> s = %Q{a,"""b"""}
=> "a,"""b""""
>> s
=> "a,"""b""""
>> s.split_csv
=> ["a", """b"""]
>> s.split_csv(:none)
=> ["a", """"b""""]
>> s.split_csv(:double)
=> ["a", """b"""]
>> s.split_csv(:mixed)
=> ["a", """b"""]
>> s.split_csv
=> ["a", """b"""]
>> exit









