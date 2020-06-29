a = [1,2,3,10]
# c = a.map {|x| {|y| x >= y}} won't work because proc =/= object
c = a.map {|x| lambda {|y| x >= y}} # will work

c[2].call 17
j = c.count {|x| x.call(1)}

puts "The value of x is #{j}" # 3