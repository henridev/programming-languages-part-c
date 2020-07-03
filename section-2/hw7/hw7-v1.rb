class GeometryExpression  
    Epsilon = 0.00001
end
  
class GeometryValue 
    
    private # some helper methods that may be generally useful
    def real_close(r1,r2) 
        (r1 - r2).abs < GeometryExpression::Epsilon
    end

    def real_close_point(x1,y1,x2,y2) 
        real_close(x1,x2) && real_close(y1,y2)
    end

    # two_points_to_line could return a Line or a VerticalLine
    def two_points_to_line(x1,y1,x2,y2) 
        if real_close(x1,x2)
        VerticalLine.new x1
        else
        m = (y2 - y1).to_f / (x2 - x1)
        b = y1 - m * x1
        Line.new(m,b)
        end
    end

    public
    # we put this in this class so all subclasses can inherit it:
    # the intersection of self with a NoPoints is a NoPoints object
    def intersectNoPoints np
        np # could also have NoPoints.new here instead
    end

    # first intersecting with the line containing the segment and then
    # calling the result's intersectWithSegmentAsLineResult with the segment
    def intersectLineSegment seg
        # this is the intersect defined in method calling on 
        # intersectlinesegment
        line_result = intersect(two_points_to_line(seg.x1,seg.y1,seg.x2,seg.y2))
        line_result.intersectWithSegmentAsLineResult seg
    end

    def eval_prog env 
        self 
    end

    def preprocess_prog
        self
    end
end

class NoPoints < GeometryValue
    # do *not* change this class definition: everything is done for you
    # (although this is the easiest class, it shows what methods every subclass of geometry values needs)

    def shift(dx,dy)
        self 
    end

    def intersect other
        other.intersectNoPoints self 
    end

    def intersectPoint p
        self 
    end

    def intersectLine line
        self 
    end

    def intersectVerticalLine vline
        self 
    end

    # if self is the intersection of (1) some shape s and (2) 
    # the line containing seg, then we return the intersection of the  shape s and the seg.  seg is an instance of LineSegment
    def intersectWithSegmentAsLineResult seg
        # self is the intersection 
        self
    end

end


class Point < GeometryValue
    # Note: You may want a private helper method like the local
    # helper function inbetween in the ML code
    attr_reader :x, :y
    def initialize(x,y)
        @x = x
        @y = y
    end

    def inBetween(v, end1, end2) 
        epsilon = GeometryExpression::Epsilon
        if (end1 - epsilon) <= v && v <= (end2 + epsilon)
          return true
        elsif (end2 - epsilon) <= v && v <= (end1 + epsilon)
          return true
        else 
          return false 
        end
    end 

    def shift(dx,dy) 
        Point.new(x + dx, y + dy)
    end

    # -- double dispatching --
    def intersect v2 # first dispatch
        v2.intersectPoint self
    end

    # means arg passed was also point 
    def intersectPoint p
        if real_close_point(x,y,p.x,p.y)
          self
        else 
          NoPoints.new
        end
    end

    def intersectLine line
        if real_close(y, ((line.m * x) + line.b))
          self
        else 
          NoPoints.new
        end
    end

    def intersectVerticalLine vline
        if real_close(x, vline.x) 
          self
        else 
          NoPoints.new
        end
    end

    def intersectWithSegmentAsLineResult seg
        x1 = seg.x1
        x2 = seg.x2
        y1 = seg.y1
        y2 = seg.y2
        if inBetween(x, x1, x2) && inBetween(y, y1, y2)
          self
        else 
          NoPoints.new
        end
    end    
end

class Line < GeometryValue
    attr_reader :m, :b 
    def initialize(m,b)
        @m = m
        @b = b
    end


    def shift(dx,dy) 
        Line.new(m, b + dy - (m * dx))
    end

    def intersect v2 # first dispatch
        v2.intersectLine self
    end
    # --- here 
    def intersectPoint p
        p.intersectLine self
    end

    def intersectLine line
        if real_close(m,line.m)
            (if real_close(b,line.b)
               self # same line
             else 
               NoPoints.new # parallel lines do not intersect
             end) 
          else # one-point intersection
            x = (line.b - b).to_f / (m - line.m)
            y = m * x + b
            Point.new(x,y)
        end
    end

    def intersectVerticalLine vline
        Point.new(vline.x, ((m * vline.x) + b))
    end

    def intersectWithSegmentAsLineResult seg
        seg
    end
end

class VerticalLine < GeometryValue
    attr_reader :x
    def initialize x
        @x = x
    end

    def shift(dx,dy) 
        VerticalLine.new(x + dx)
    end

    def intersect v2 # first dispatch
        v2.intersectVerticalLine self
    end

    def intersectPoint p
        p.intersectVerticalLine self
    end

    def intersectLine line
        line.intersectVerticalLine self
    end

    def intersectVerticalLine vline
      if real_close(x, vline.x) 
        self
      else 
        NoPoints.new
      end
    end

    def intersectWithSegmentAsLineResult seg
        seg
    end
end

class LineSegment < GeometryValue
    # In the sample solution 
    # - preprocess_prog is about 15 lines long and 
    # - intersectWithSegmentAsLineResult is about 40 lines long

    attr_reader :x1, :y1, :x2, :y2
    def initialize (x1,y1,x2,y2)
        @x1 = x1
        @y1 = y1
        @x2 = x2
        @y2 = y2
    end

  
    def preprocess_prog
        if real_close_point(x1,y1,x2,y2)
            Point.new(x1, y1)   
        elsif x1 > x2
            LineSegment.new(x2,y2,x1,y1)
        elsif real_close(x1, x2) && y1 >= y2
            LineSegment.new(x2,y2,x1,y1)
        else 
            self            
        end
    end

    def shift(dx,dy) 
        LineSegment.new(x1+dx,y1+dy,x2+dx,y2+dy)
    end

    def intersect v2 
        # first dispatch pass the segment to general function
        # this creates a line or vertical line 
        # with this line or vertical line 
        v2.intersectLineSegment self
    end

    def intersectPoint point
        point.intersectLineSegment self
    end

    
    def intersectLine line
        line.intersectLineSegment self
    end

    def intersectVerticalLine vline
        vline.intersectLineSegment self
    end


    def intersectWithSegmentAsLineResult seg
        # self = seg2
        x1start = seg.x1
        y1start = seg.y1
        x1end = seg.x2
        y1end = seg.y2
        x2start = x1
        y2start = y1
        x2end = x2
        y2end = y2
        if y1start < y2start
            v = { "aXstart" => x1start, "aYstart" => y1start, 
                  "aXend" => x1end, "aYend" => y1end, 
                  "bXstart" => x1, "bYstart" => y1, 
                  "bXend" => x2, "bYend" => y2 }
        else
            v = { "bXstart" => x1start, "bYstart" => y1start, 
                  "bXend" => x1end, "bYend" => y1end, 
                  "aXstart" => x1, "aYstart" => y1, 
                  "aXend" => x2, "aYend" => y2 }
        end
        if real_close(x1start, x1end)
          if real_close(v["aYend"],v["bYstart"])
              Pointnew(v["aXend"],v["aYend"])
          elsif v["aYend"] < v["bYstart"]
              NoPoints.new
          elsif v["aYend"] > v["bYend"]
                LineSegment.new(v["bXstart"],v["bYstart"],v["bXend"],v["bYend"])
          else 
            LineSegment.new(v["bXstart"],v["bYstart"],v["aXend"],v["aYend"])
          end
        else
          if real_close(v["aXend"],v["bXstart"])
            Pointnew(v["aXend"],v["aYend"])
          elsif v["aXend"] < v["bXstart"]
            NoPoints.new
          elsif v["aXend"] > v["bXend"]
            LineSegment.new(v["bXstart"],v["bYstart"],v["bXend"],v["bYend"])
          else 
            LineSegment.new(v["bXstart"],v["bYstart"],v["aXend"],v["aYend"])
          end
       end
  end
end

# Note: there is no need for getter methods for the non-value classes

class Intersect < GeometryExpression
    def initialize(e1,e2)
        @e1 = e1
        @e2 = e2
    end

    def eval_prog env 
        @e1.eval_prog(env).intersect(@e2.eval_prog(env))
    end

    def preprocess_prog
        Intersect.new(@e1.preprocess_prog, @e2.preprocess_prog)
    end
end

class Let < GeometryExpression
    def initialize(s,e1,e2)
        @s = s
        @e1 = e1
        @e2 = e2
    end

    def eval_prog env 
        # create new env don't just extend it 
        # unshift to put infront so that it will shadow vars with same 
        # name already defined
        @e2.eval_prog(env.map { |i| i }.unshift([@s, @e1.eval_prog(env)]))
    end

    def preprocess_prog
        Let.new(@s, @e1.preprocess_prog, @e2.preprocess_prog)
    end
    
end

class Var < GeometryExpression
    def initialize s
        @s = s
    end

    def eval_prog env 
        pr = env.assoc @s 
        raise "undefined variable" if pr.nil?
        pr[1]
    end

    def preprocess_prog
        self
    end

end

class Shift < GeometryExpression
    def initialize(dx,dy,e)
        @dx = dx
        @dy = dy
        @e = e
    end
    
    def eval_prog env
        @e.eval_prog(env).shift(@dx, @dy)
    end
    
    def preprocess_prog
        Shift.new(@dx, @dy, @e.preprocess_prog)
    end
end

