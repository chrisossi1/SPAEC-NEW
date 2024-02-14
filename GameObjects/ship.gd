extends SolidObject
class_name objShip

#Todo: Change to Node?

@onready var ch_engine = get_node("Engine")


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
#Args: Shape, composition? or substance? bodyInitArgs
func init(bodyInitArgs):
	ch_body.callv("init", bodyInitArgs)

	var composition := {Substances.ferrosteel:1}
	ch_body.ch_solidProperties.set_composition(composition) #TODO: wrap this in a SolidObject function
	ch_body.ch_solidProperties.integrity = 10000
	ch_body.ch_solidProperties.max_integrity = 10000
	var ship_poly = regular_poly(3,100)*Transform2D(0,Vector2(1,.5),0,Vector2.ZERO)
	set_polygon(Polygon.new(ship_poly))

	#todo: generate text description of asteroid - asteroid, debris, megaAsteroid, cryoasteroid, etc.
	objName = "Ship"
