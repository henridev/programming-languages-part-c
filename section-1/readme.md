## ruby oop in short 

5 rules
- all vals are refs to objects
- methods communicate with objects 
- object has own private state only modifiable via methods
- every object is instance of a class (instead of prototypical)
- class determines object behaviour 

> classes and methods in ruby 

```ruby
# e.m() e is an expression m is some method
class Name 
    def method_name1 method_args1
        expression1
    end
    def method_name2 method_args2
        self.method_name1
    end
end

name = Name.new
```

**self** key-word = current object whose method is executing
--> we can return object itself within it's methods to 

```ruby
# e.m() e is an expression m is some method
class Textmachine 
    def m1 
        print "hi "
        self
    end
    def m2 
        print "welcome "
        self
    end
    def m3 
        print "bye "
        self
    end
end

machine = Textmachine.new
machine.m1.m2.m3 # hi welcome bye
```

**object state**

- only via methods accessible
- persists after creation
- contains **instance variables**
```ruby
# e.m() e is an expression m is some method
class A =
    def m1 
        @foo = 0 # if it has a foo var it will change it to zero else it will create one and initialize it to zero
    end
end
```

> **aliasing** = when we say `x=y` because values are refs to objects 
> x will now refer to the same object as y

> **initiliaze** = like a constructor in js 
> - this gets called before object returns

```ruby
# e.m() e is an expression m is some method
class Textmachine =
    def initialize(f) 
        @foo = f
    end
    def m1 
        @foo
    end
end

machine = Textmachine.new("hi")
```


- class variables = shared by entire class accessible via all instances
- class constants = publicly accesible outside class as well 
- class mehtods
```ruby
# e.m() e is an expression m is some method
class A =
    CONSTANT_NAME = ["a", "b", "c"] # class constant 
    @@availble_anywhere = [] # class variables 
    def self.m1 
       @@availble_anywhere
    end
end

A.m1
```

> object state is private 

-> instance variables can only be accessed via an object's method
-> getters and setters are necessary for public access

```ruby
# shorthand syntac
def foo
    @foo
end
def foo= x
    @foo = x
end

e.foo = 42
```

## blocks and procs

**blocks**
- like closures in that they can use variables from before there definition
- not-like closures in that they can't be passed or stored like closures
- they are not objects you can just pass 1 or 0 blocks to any method
- you can define your own blocks and call them in function bodies via `puts`

```ruby
# shorthand syntac
sum = 0
[1,2,3].each { |x|
    sum += x
    puts sum
}
[1,2,3].each begin |x|
    sum += x
    puts sum
end

def foo x
    yield x
end

foo ("hi") { |msg| puts msg} 
```

**Procs**
- a proc is an instance of the Proc class which implements a true closure

```ruby
a = [1,2,3,10]
# c = a.map {|x| {|y| x >= y}} won't work because proc =/= object
c = a.map {|x| lambda {|y| x >= y}} # will work

c[2].call 17
j = c.count {|x| x.call(1)}

puts "The value of x is #{j}" # 3
```

