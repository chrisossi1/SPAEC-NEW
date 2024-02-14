extends GameObject
class_name SolidObject


@onready var ch_body := get_node_or_null("RigidBody2D") as RigidBody2D_

func _ready():
	super._ready()
	ch_body.parentGameObject = self

func set_substance(s: Dictionary) -> void:
	ch_body.ch_solidProperties.set_substance(s)
	
func set_polygon(p: Polygon) -> void:
	ch_body.set_polygon(p)



















'''POLYGON GENERATION'''

var regularPolys = {}
func cache_regularPolys():
	for i in range(3,11):
		regularPolys[i] = _generate_regularPoly(i)

'''includes cached polys'''
func regular_poly(sides:int,size:float) -> PackedVector2Array:
	if sides in regularPolys.keys():
		var xform = Transform2D(0,Vector2(size,size),0,Vector2.ZERO)
		return regularPolys[sides] * xform
	return _generate_regularPoly(sides,size)




'''pseudoprivate'''
'''Does not have repeated first and last element for polyline closure, needs to be handled in draw'''
func _generate_regularPoly(sides:int, size := 1) -> PackedVector2Array:
	var poly = PackedVector2Array([])
	for i in range(sides):
		poly.append(size*Vector2(cos(2*PI*float(i)/sides),sin(2*PI*float(i)/sides))) #todo: use rotated()?
	return poly
