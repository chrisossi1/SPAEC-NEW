extends Node2D

var accelerating
var decelerating
var turnLeft
var turnRight
var angularBraking
var braking
	
# Called when the node enters the scene tree for the first time.

@export var tool_path:NodePath
@onready var tool = null# get_node(tool_path) as Node2D


#@export var engine: ShipEngine
var engine:ShipEngine

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not engine:
		return

	if Input.is_action_pressed("debugInput"):
		for obj in engine.tetheredObjs:
			obj.drawing.set_overwrite_color(Color.MAGENTA)
	
	
	engine.set_control("up",false)
	engine.set_control("down",false)
	engine.set_control("left",false)
	engine.set_control("right",false)
	#engine.set_control("directionReference",get_viewport().get_camera_2d().get_rotation())
	engine.set_control("moveToPoint",Vector2.INF)
	
	
	if Input.is_action_pressed("up"):
		engine.set_control("up",true)
	if Input.is_action_pressed("down"):
		engine.set_control("down",true)
	if Input.is_action_pressed("left"):
		engine.set_control("left",true)
	if Input.is_action_pressed("right"):
		engine.set_control("right",true)

	engine.set_control("moveToPoint",Vector2.INF)
	if (Input.is_action_pressed("up") and Input.is_action_pressed("down")) or (Input.is_action_pressed("left") and Input.is_action_pressed("right")):
		engine.set_control("moveToPoint",get_global_mouse_position())

	#tool.set_target(get_global_mouse_position())

'''	
func use_tool(start := true):
	if start:
		tool.set_target(get_global_mouse_position())
		tool.start()
	else:
		tool.end()
'''
