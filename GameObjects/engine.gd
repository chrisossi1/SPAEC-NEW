extends Node
class_name ShipEngine

@export var rigidBody : RigidBody2D_
var tetherable = null


var controlsDict = {}
var controlsKeys = ["up","down","left","right","directionReference","moveToPoint"]

func _ready():
	if tetherable:
		tetherable.engine = self
	
	for key in controlsKeys:
		controlsDict[key] = false
	controlsDict["directionReference"] = 0.0
	controlsDict["moveToPoint"] = Vector2.INF
	


#called every frame to set ship controls. TODO: called only upon update event

func set_control(key,control):
	if key not in controlsKeys:
		print('bAD CONTROL KEY '+str(key))
		return

	controlsDict[key] = control

var turn = 800 #base turning impulse
var speed = 200

var TURNING_ANGULAR = 5 #target angular velocity

var DEFAULT_ANGULAR_DAMP = 0 #rest angular damp
var ACCELERATING_ANGULAR_DAMP = 0 #angular damp while accelerating linearly and not turning

var MAX_ANGULAR = 10 #max angular velocity, beyond which the limiting angular damp is applied
var LIMIT_ANGULAR_DAMP = 10

var BRAKE_LINEAR_DAMP = 10
var TETHER_BRAKE_LINEAR_DAMP = 2
var TETHER_DEFAULT_ANGULAR_DAMP = .8


var BASE_ACC = 25


func _physics_process(delta):
	var targetDirection = Vector2.ZERO
	
	if controlsDict["moveToPoint"] != Vector2.INF:
		targetDirection = rigidBody.get_position().direction_to(controlsDict["moveToPoint"])
	else:
		if controlsDict["left"]:
					
			targetDirection += Vector2(-1,0)
		
		if controlsDict["right"]:
			targetDirection += Vector2(1,0)
			
		if controlsDict["up"]:
			targetDirection += Vector2(0,-1)
		
		if controlsDict["down"]:
			targetDirection += Vector2(0,1)
			
		targetDirection = targetDirection.rotated(controlsDict["directionReference"])

	if targetDirection == Vector2.ZERO:
		rigidBody.set_angular_damp(LIMIT_ANGULAR_DAMP)
		rigidBody.set_linear_damp(BRAKE_LINEAR_DAMP)
	else:
		rigidBody.set_angular_damp(DEFAULT_ANGULAR_DAMP)
		rigidBody.set_linear_damp(0)
		move_in_direction(targetDirection)
	
	if tetherable:
		move_tethered_objects()
	
	
	
	
	

	
	
'''PI Controller to direction'''
func move_in_direction(targetDirection:Vector2):
	#Current facing direction
	var currentDirection := Vector2(1,0).rotated(rigidBody.get_rotation()).normalized()
	
	#rotating ship
	var dot = Vector2(1,0).rotated(rigidBody.get_rotation()).normalized().dot(targetDirection)
	var clampedDot = max(0,dot)
	var linear_impulse = speed * Vector2(clampedDot,0).rotated(rigidBody.get_rotation())

	rigidBody.apply_central_impulse(linear_impulse)

	#Proportional and derivative components of ship angle
	var angErr := currentDirection.rotated(PI/2).dot(targetDirection.normalized())
	var bodyAngularVel = rigidBody.get_angular_velocity()
	var angDampFactor = -bodyAngularVel

	var turnAdjust = 0
	if dot <-.95:
		turnAdjust = 10000 * sign(bodyAngularVel+.0000001)

	rigidBody.apply_torque_impulse(4000*angErr+600*angDampFactor+turnAdjust)

	var velocityError = targetDirection * speed - rigidBody.get_linear_velocity()
	rigidBody.apply_central_impulse(velocityError*.1)
	






func move_tethered_objects():
	for obj in tetheredObjs:
		if obj == rigidBody.parentGameObject:
				continue
				
		obj.rigidBody.set_linear_damp(0)
		obj.rigidBody.set_angular_damp(TETHER_DEFAULT_ANGULAR_DAMP)
		
		'''Proportional controller to match tethered obj velocity to ship velocity (slightly)'''
		var error = rigidBody.get_linear_velocity() - obj.get_body_velocity()
		var p = .1
		obj.rigidBody.apply_central_impulse(p*error)
		




	
		
'''List of tether references'''
var tetheredObjs = []
func add_TetheredObj(obj:SolidObject):
	if not obj in tetheredObjs and obj != rigidBody.parentGameObject:
		tetheredObjs.append(obj)
		
func remove_TetheredObj(obj:SolidObject):
	tetheredObjs.erase(obj)
