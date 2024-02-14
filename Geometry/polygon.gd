extends Node
class_name Polygon

'''
Container class for polygon geometry
'''

var points:PackedVector2Array #Points of poly
var n:int #number of sides for poly
var area:float #area of poly
var diameter:float #diameter of poly
var centroid:Vector2 #centroid based on area of shape

#area, diameter, centroid are all calculated as-needed when set or updated

var initialized:=false
func _init(p:PackedVector2Array):
	points = p
	set_poly(p)
	initialized = true
	
func set_poly(p:PackedVector2Array):
	n = len(points)
	
	var areaAndCentroid = calculate_area_COM(points)
	area = areaAndCentroid[0]
	centroid = areaAndCentroid[1]

	var hull = Geometry2D.convex_hull(points)
	diameter = calculate_diameter(hull)


func valid() -> bool:
	return area > 0
	
	
'''Returns [area,COM] pair (as opposed to centroid which is COM of vertices)'''
func calculate_area_COM(poly: PackedVector2Array) -> Array:
	var area_sum = 0.0
	var centroid_sum = Vector2.ZERO

	for i in range(poly.size()):
		var v1 = poly[i]
		var v2 = poly[(i + 1) % poly.size()]

		var cross_product = v1.cross(v2)
		area_sum += cross_product

		centroid_sum += (v1 + v2) * cross_product

	if area_sum == 0.0:
		return [0,Vector2.ZERO]

	var COM = centroid_sum / (3.0 * area_sum)
	return [area_sum,COM]
	
	
#A function to calculate the width of the smallest rotated bounding rect
func calculate_diameter(poly:PackedVector2Array) -> float:
	var n = len(poly)
 
	assert (n>2)
 
	var k := 1
   
	while (triangleArea(poly[n-1], poly[0], poly[(k+1)%n]) > triangleArea(poly[n-1], poly[0], poly[k])):
		k+=1
 
	var maxDistSquared := 0.
	var j = k
	for i in range(k):# (int i = 0, j = k; i <= k; i++) {
		while triangleArea(poly[i], poly[(i+1)%n], poly[(j+1)%n]) > triangleArea(poly[i], poly[(i+1)%n], poly[j]):
			maxDistSquared = max(maxDistSquared, poly[i].distance_squared_to(poly[(j+1)%n]))
			j = (j+1) % n
  
		maxDistSquared = max(maxDistSquared, poly[i].distance_squared_to(poly[j]))

	return sqrt(maxDistSquared)
	

func intersect_with_line(start:Vector2,end:Vector2) -> Array:
	var intersections := []
	var firstIntersection = null
	var firstIntersectionLengthSquared = 999999999999
	var secondIntersection = null
	var secondIntersectionLengthSquared = 999999999999
	
	for i in range(n):
		var intersection = Geometry2D.segment_intersects_segment(start,end,points[i],points[(i+1) % n])
		if not intersection:
			continue
		
		var d = (intersection - start).length_squared()
		if d < firstIntersectionLengthSquared:
			firstIntersection = intersection
			firstIntersectionLengthSquared = d
		elif d < secondIntersectionLengthSquared and d > firstIntersectionLengthSquared:
			secondIntersection = intersection
			secondIntersectionLengthSquared = d

	return [firstIntersection,secondIntersection]





func cut_through_centroid(cutPoint:Vector2, perpendicular := false) -> Array:
	var cutLine =  centroid - cutPoint
	return cut_along_line(centroid,cutLine,perpendicular)


	
	
	
	

func cut_along_line(cutPoint:Vector2,cutDir:Vector2, perpendicular := false) -> Array:
	var newPolys = []
	
	var cutLine = cutDir.normalized()*diameter*2
	if perpendicular:
		cutLine = cutLine.rotated(PI/2)
		
	#the normal to the cutting line to construct the rectangle
	var normal = cutLine.rotated(PI/2) 
	
	var a = cutPoint - cutLine
	var b = cutPoint + cutLine
	var c = b + normal
	var d = a + normal
	

	var cutPoly = PackedVector2Array([a,b,c,d,a])

	var piece1 = Geometry2D.intersect_polygons(points,cutPoly)
	var piece2 = Geometry2D.clip_polygons(points,cutPoly)

	var pieces = []
	for p in piece1+piece2:
		var poly = Polygon.new(p)
		if not poly.valid():
			continue
		pieces.append(poly)

	return pieces
	


'''UGH i cant doit'''
func cut_along_zigzag(cutPoint:Vector2,cutDir:Vector2, perpendicular := false) -> Array:
	var newPolys = []
	
	var cutLine = cutDir.normalized()*diameter*2
	if perpendicular:
		cutLine = cutLine.rotated(PI/2)
		
	#the normal to the cutting line to construct the rectangle
	var normal = cutLine.rotated(PI/2) 
	
	var a = cutPoint - cutLine
	var b = cutPoint + cutLine
	var c = b + normal
	var d = a + normal
	
	var cutPoly = PackedVector2Array([a,Vector2(randi_range(-800,800),randi_range(-800,800)),Vector2(randi_range(-800,800),randi_range(-800,800)),b,c,d,a])

	
	var piece1 = Geometry2D.intersect_polygons(points,cutPoly)
	var piece2 = Geometry2D.clip_polygons(points,cutPoly)

	var pieces = []
	for p in piece1+piece2:
		var poly = Polygon.new(p)
		if not poly.valid():
			continue
		pieces.append(poly)

	return pieces
	




#grow/shrink polygon
func offset(amount:int,joinType:Geometry2D.PolyJoinType):
	var offsetPolys = Geometry2D.offset_polygon(points,amount,joinType)
	if len(offsetPolys) != 1:
		return false
		
	set_poly(offsetPolys)
	
	return true

#Centers the points around the centroid, translating it to origin
func center_area_centroid():
	for i in range(n):
		points[i] -= centroid
		
	centroid = Vector2.ZERO
	
	
	
#util func for area of a tri
func triangleArea(p:Vector2, q:Vector2, r:Vector2) -> float:
	return abs((p.x * q.y + q.x * r.y + r.x * p.y) - (p.y * q.x + q.y * r.x + r.y * p.x))
