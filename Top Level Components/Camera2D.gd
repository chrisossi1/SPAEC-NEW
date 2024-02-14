extends Camera2D

'''
TODO:
	
Margin zooming is pretty annoying because the camera is always moving when you are trying to click something.
Maybe make it speed dependent zooming and offset? (eg. zoom out when moving fast and move the camera ahead a bit in the direction of travel)



'''






@export var cameraTarget: Node2D

const ROTATE_SPEED := .005*PI
var targetRotation := 0.
var baseZoomAmount := 1. #zoom amount from manual set
var zoomAmount := 1. #zoom amount from mouse margin

const CAMSPEED := .5
const ROTSPEED := .1
const ZOOMSPEED := .03


var MARGIN = 80 #Margin for mouse on border in pixels
func _physics_process(delta):
	if rotateCW:
		targetRotation+=ROTATE_SPEED
	if rotateCCW:
		targetRotation-=ROTATE_SPEED
	
	
	
	var viewPortSize := get_viewport().get_size() as Vector2
	viewPortSize /= zoom
	
	#Get position of mouse on screen
	var localMousePos = get_viewport().get_mouse_position()/zoom
	
	var clampedLocalMousePos = Vector2(clamp(localMousePos.x,MARGIN,viewPortSize.x-MARGIN),clamp(localMousePos.y,MARGIN,viewPortSize.y-MARGIN))
			
	var normLocalMousePos = clampedLocalMousePos / viewPortSize

	var normEasedMousePos := Vector2(custom_ease(normLocalMousePos.x,.25,.5),custom_ease(normLocalMousePos.y,.25,.5))

	var easedMousePos := (normEasedMousePos-Vector2(.5,.5)) * viewPortSize
	var globalEasedMousePos = to_global(easedMousePos)
	var targetPos = (cameraTarget.get_position() + globalEasedMousePos)/2
	
	zoomAmount = 1
	if localMousePos.x < MARGIN or localMousePos.y < MARGIN or localMousePos.x > viewPortSize.x-MARGIN or localMousePos.y > viewPortSize.y-MARGIN:
		zoomAmount = .5
	set_zoom(ZOOMSPEED*Vector2.ONE*zoomAmount + zoom*(1-ZOOMSPEED))
	
	var camera_position = CAMSPEED*targetPos+position*(1-CAMSPEED)
	var camera_rotation = ROTSPEED*targetRotation + rotation*(1-ROTSPEED)
	set_position(camera_position)
	set_rotation(camera_rotation)

	$Background.size = get_viewport().size*2
	$Background.position = -get_viewport().size
	
	
	


var rotateCW := false
var rotateCCW := false
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_COMMA:
				rotateCCW = true
			if event.keycode == KEY_PERIOD:
				rotateCW = true
		else:
			if event.keycode == KEY_COMMA:
				rotateCCW = false
			if event.keycode == KEY_PERIOD:
				rotateCW = false




const FLOAT_EPSILON = 0.00001

func custom_ease(x:float,s:float,t:float):
	#https://arxiv.org/pdf/2010.09714.pdf
	if x < t:
		return  t*x / (x + (s*(t-x)) + FLOAT_EPSILON)	
		
	else:
		return  1 + (1-t)*(x-1)/(1 - x - (s*(t-x)) + FLOAT_EPSILON)
