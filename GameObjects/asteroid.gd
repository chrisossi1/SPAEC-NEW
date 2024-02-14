extends SolidObject
class_name objAsteroid

#Todo: Change to Node?

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	

#Args: Shape, composition? or substance? bodyInitArgs
func init(bodyInitArgs,polygon = Polygon.new(regular_poly(6,100))):
	ch_body.callv("init", bodyInitArgs)

	var composition := {Substances.rock:1}
	ch_body.ch_solidProperties.set_composition(composition) #TODO: wrap this in a SolidObject function

	var integrity = max(polygon.area*.1,50)
	var max_integrity = max(polygon.area*.1,50)
	
	ch_body.ch_solidProperties.max_integrity = integrity#wrap this in a SolidObject function
	ch_body.ch_solidProperties.integrity = integrity
	set_polygon(polygon)
	
	#todo: generate text description of asteroid - asteroid, debris, megaAsteroid, cryoasteroid, etc.
	objName = "Asteroid"


'''
1. The obj preload and init args are queued and then reach the end of the queue
2. The obj is added to Main tree, initializing child/parent structure and running main funcs
2. The obj is instanced and its init function is run



'''
