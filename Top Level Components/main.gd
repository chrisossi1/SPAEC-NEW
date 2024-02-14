extends Node2D

var player:objShip
@onready var camera = get_node("Camera2D") as Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.create_gameObj.connect(create_gameObj)

	for i in range(2000):
		var pos := Vector2(randi_range(-10000,10000),randi_range(-10000,10000))
		create_gameObj(GlobalSignals.asteroid,[[Transform2D(0,pos),Transform2D(randf_range(-2,2),Vector2.LEFT.rotated(randf_range(0,PI)))]])

	player = create_gameObj(GlobalSignals.ship,[[Transform2D(0,Vector2.ONE*200),Transform2D()]])
	$PlayerInput.engine = player.ch_engine
	camera.cameraTarget = player.ch_body

'''Creation queue item is of form [ObjType, InitArgs of form [args..], BodyInitArgs: of form [xform(Pos/Rot), xform(LinVel,AngVel)]'''		
func create_gameObj(objToCreate:PackedScene,arguments:Array):
		var newObject:GameObject = objToCreate.instantiate()
		add_child(newObject)
		newObject.callv("init", arguments)
		
		return newObject
