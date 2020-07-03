
datatype geom_exp = 
           NoPoints
	 | Point of real * real 
	 | Line of real * real 
	 | VerticalLine of real 
	 | LineSegment of real * real * real * real 
	 | Intersect of geom_exp * geom_exp 
	 | Let of string * geom_exp * geom_exp 
	 | Var of string
     | Shift of real * real * geom_exp (* CHANGE add shifts for expressions of the form Shift(deltaX, deltaY, exp *)

exception BadProgram of string
exception Impossible of string



val epsilon = 0.00001

fun real_close (r1,r2) = 
    (Real.abs (r1 - r2)) < epsilon


fun real_close_point (x1,y1) (x2,y2) = 
    real_close(x1,x2) andalso real_close(y1,y2)

fun two_points_to_line (x1,y1,x2,y2) = 
    if real_close(x1,x2)
    then VerticalLine x1
    else
	let 
	    val m = (y2 - y1) / (x2 - x1)
	    val b = y1 - m * x1
	in
	    Line(m,b)
	end


fun intersect (v1,v2) =
    case (v1,v2) of
	
       (NoPoints, _) => NoPoints (* 5 cases *)
     | (_, NoPoints) => NoPoints (* 4 additional cases *)

     | 	(Point p1, Point p2) => if real_close_point p1 p2
				then v1
				else NoPoints

      | (Point (x,y), Line (m,b)) => if real_close(y, m * x + b)
				     then v1
				     else NoPoints

      | (Point (x1,_), VerticalLine x2) => if real_close(x1,x2)
					   then v1
					   else NoPoints

      | (Point _, LineSegment seg) => intersect(v2,v1)

      | (Line _, Point _) => intersect(v2,v1)

      | (Line (m1,b1), Line (m2,b2)) =>
				if real_close(m1,m2) 
				then (if real_close(b1,b2)
					then v1 (* same line *)
					else  NoPoints) (* parallel lines do not intersect *)
				else 
					let (* one-point intersection *)
					val x = (b2 - b1) / (m1 - m2)
					val y = m1 * x + b1
					in
					Point (x,y)
					end

      | (Line (m1,b1), VerticalLine x2) => Point(x2, m1 * x2 + b1)

      | (Line _, LineSegment _) => intersect(v2,v1)

      | (VerticalLine _, Point _) => intersect(v2,v1)
      | (VerticalLine _, Line _)  => intersect(v2,v1)

      | (VerticalLine x1, VerticalLine x2) =>
					if real_close(x1,x2)
					then v1 (* same line *)
					else NoPoints (* parallel *)

      | (VerticalLine _, LineSegment seg) => intersect(v2,v1)

      | (LineSegment seg, _) => 
			(* the hard case, actually 4 cases because v2 could be a point,
			line, vertical line, or line segment *)
			(* First compute the intersection of (1) the line containing the segment 
				and (2) v2. Then use that result to compute what we need. *)
			(case intersect(two_points_to_line seg, v2) of
				NoPoints => NoPoints 
			| Point(x0,y0) => (* see if the point is within the segment bounds *)
				(* assumes v1 was properly preprocessed *)
				let 
				fun inbetween(v,end1,end2) =
					(end1 - epsilon <= v andalso v <= end2 + epsilon)
					orelse (end2 - epsilon <= v andalso v <= end1 + epsilon)
				val (x1,y1,x2,y2) = seg
				in
				if inbetween(x0,x1,x2) andalso inbetween(y0,y1,y2)
				then Point(x0,y0)
				else NoPoints
				end
			| Line _ => v1 (* so segment seg is on line v2 *)
			| VerticalLine _ => v1 (* so segment seg is on vertical-line v2 *)
			| LineSegment seg2 => 
				(* the hard case in the hard case: seg and seg2 are on the same
					line (or vertical line), but they could be (1) disjoint or 
					(2) overlapping or (3) one inside the other or (4) just touching.
				And we treat vertical segments differently, so there are 4*2 cases.
				*)
				let
				val (x1start,y1start,x1end,y1end) = seg
				val (x2start,y2start,x2end,y2end) = seg2
				in
				if real_close(x1start,x1end)
				then (* the segments are on a vertical line *)
					(* let segment a start at or below start of segment b *)
					let 
					val ((aXstart,aYstart,aXend,aYend),
						(bXstart,bYstart,bXend,bYend)) = if y1start < y2start
										then (seg,seg2)
										else (seg2,seg)
					in
					if real_close(aYend,bYstart)
					then Point (aXend,aYend) (* just touching *)
					else if aYend < bYstart
					then NoPoints (* disjoint *)
					else if aYend > bYend
					then LineSegment(bXstart,bYstart,bXend,bYend) (* b inside a *)
					else LineSegment(bXstart,bYstart,aXend,aYend) (* overlapping *)
					end
				else (* the segments are on a (non-vertical) line *)
					(* let segment a start at or to the left of start of segment b *)
					let 
					val ((aXstart,aYstart,aXend,aYend),
						(bXstart,bYstart,bXend,bYend)) = if x1start < x2start
										then (seg,seg2)
										else (seg2,seg)
					in
					if real_close(aXend,bXstart)
					then Point (aXend,aYend) (* just touching *)
					else if aXend < bXstart
					then NoPoints (* disjoint *)
					else if aXend > bXend
					then LineSegment(bXstart,bYstart,bXend,bYend) (* b inside a *)
					else LineSegment(bXstart,bYstart,aXend,aYend) (* overlapping *)
					end	
				end						
			| _ => raise Impossible "bad result from intersecting with a line")
			| _ => raise Impossible "bad call to intersect: only for shape values"




fun eval_prog (e,env) =
    case e of
	NoPoints => e (* first 5 cases are all values, so no computation *)
      | Point _  => e
      | Line _   => e
      | VerticalLine _ => e
      | LineSegment _  => e
      | Var s => 
	(case List.find (fn (s2,v) => s=s2) env of
	     NONE => raise BadProgram("var not found: " ^ s)
	   | SOME (_,v) => v)
      | Let(s,e1,e2) => eval_prog (e2, ((s, eval_prog(e1,env)) :: env))
      | Intersect(e1,e2) => intersect(eval_prog(e1,env), eval_prog(e2, env))
      | Shift(dx, dy, e1) =>
        case eval_prog(e1, env) of
            NoPoints => NoPoints
          | Point(x, y) => Point(x + dx, y + dy)
          | Line(m, b) => Line(m, b + dy - m * dx)
          | VerticalLine(x) => VerticalLine(x + dx)
          | LineSegment(x1, y1, x2, y2) => LineSegment(x1 + dx, y1 + dy, x2 + dx, y2 + dy)


fun preprocess_prog e =
	case e of
	LineSegment(x1, y1, x2, y2) 
		=> if real_close_point (x1, y1) (x2, y2)
			then Point(x1, y1)
			else if real_close(x1, x2) then
				(if y1 > y2
				then LineSegment(x2, y2, x1, y1)
				else LineSegment(x1, y1, x2, y2))
			else if(x1 > x2)
			then LineSegment(x2, y2, x1, y1)
			else e
	| Let(s, e1, e2) 
		=> Let(s, preprocess_prog(e1), preprocess_prog(e2))
	| Intersect(e1, e2)
		=> Intersect(preprocess_prog(e1), preprocess_prog(e2))
	| Shift(deltaX, deltaY, e)
		=> Shift(deltaX, deltaY, preprocess_prog(e))
	| _ => e