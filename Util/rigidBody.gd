extends RigidBody2D
class_name RigidBody2D_

'''
RigidBody2D Component

Responsibilities:
	Handle all physics calculation
	emit signal on collision
	Helper functions to locally transform direction vectors
	
	CONTAINS ALL SOLID BODY COMPONENTS?
'''

@onready var ch_collisionPoly := get_node("CollisionPolygon2D") as CollisionPolygon2D
@onready var ch_drawing := get_node("drawing") as Drawing
@onready var ch_solidProperties := get_node("solidProperties") as SolidProperties

var parentGameObject:SolidObject = null #Responsibility of parent to set

func _ready():
	set_contact_monitor(true)
	ch_solidProperties.zero_integrity.connect(integrity_failure)

func init(xform := Transform2D.IDENTITY,velocities := Transform2D.IDENTITY):
	transform = xform
	linear_velocity = velocities.get_origin()
	angular_velocity = velocities.get_rotation()
	angular_damp = 0
	linear_damp = 0



var polygon:Polygon
func set_polygon(poly:Polygon):
	ch_collisionPoly.set_polygon(poly.points)
	ch_drawing.set_polygon(poly)
	polygon = poly

func set_composition(comp:Dictionary):
	var substanceProperties = ch_solidProperties.set_composition(comp)
	ch_drawing.set_substance(substanceProperties)








const MIN_PIECE_SIZE = 3000
const MIN_BREAKABLE_SIZE = 6000






'''COLLISION HANDLING'''


var enabled := true #to prevent collision detection after object is queued for deletion?? really just to prevent duplicate asteroid splits. This flag should really be disabling all activity
var collision_monitoring = true
const COLLISION_IMPULSE_CUTOFF := 25 #length squared
const COLLISION_JERK_CUTOFF := 2

var frameAccelerationPrev = Vector2.ZERO
func _integrate_forces( state ):
	
	'''
	if not collision_monitoring:
		return
	if not enabled:
		return	
		
	'''
	var frameAcceleration = update_acceleration()
	var frameJerk = frameAcceleration - frameAccelerationPrev
	frameAccelerationPrev = frameAcceleration
	
	if frameJerk.length_squared() < COLLISION_JERK_CUTOFF:
		return
		
	var numCollisions = state.get_contact_count()
	if(numCollisions == 0):  #this check is needed or it will throw errors
		return
	
	var totalImpulse = Vector2.ZERO
	for i in range(numCollisions):
		totalImpulse += state.get_contact_impulse(i)
	
	'''This is the workaround: If there are contacts but providing 0 impulse due to first-frame bug, revert to manually counted impulse'''
	if totalImpulse == Vector2.ZERO:
		totalImpulse = frameAcceleration*get_mass()
	
	if totalImpulse.length_squared() < COLLISION_IMPULSE_CUTOFF:
		return
		
	var collisionIndex = 0
	var local_collision_impulse = rotate_to_local(totalImpulse)	#state.get_contact_impulse(collisionIndex) #See workaround
	var local_collision_pos = to_local(state.get_contact_collider_position(collisionIndex))
	var local_collision_normal = state.get_contact_local_normal(collisionIndex)
	var collidingBody = state.get_contact_collider_object(collisionIndex)
	var local_collision_object = null
	
	if collidingBody != null:
		local_collision_object = collidingBody.parentGameObject
		assert (local_collision_object is SolidObject)
	
	call_deferred("collisionHandler_body_collision",local_collision_pos,local_collision_impulse,local_collision_normal, local_collision_object)
	#onCollision.emit(local_collision_pos,local_collision_impulse,local_collision_normal, local_collision_object)

#Workaround for broken state.get_contact_impulse(), unfortunately does not filter by contact index
var prevVelocity := linear_velocity
func update_acceleration():
	var acceleration = linear_velocity - prevVelocity
	prevVelocity = linear_velocity
	return acceleration








func integrity_failure():
	if parentGameObject.objName == "Ship":
		ch_solidProperties.integrity = ch_solidProperties.max_integrity
		return
		
	if polygon.area < MIN_BREAKABLE_SIZE:
		return
	
	#print("Integrity")
	split_asteroid()
	return


'''Collision Handler'''
var lastCollision:Array
var intersections
var scaledDamage
const DAMAGE_CUTOFF = 8
func collisionHandler_body_collision(local_collision_pos,local_collision_impulse,local_collision_normal, local_collision_object:SolidObject):
	var damage = .5*local_collision_object.ch_body.ch_solidProperties.properties["hardness"]*local_collision_impulse.length()/ch_solidProperties.properties["durability"]
	if damage < DAMAGE_CUTOFF:
		return
	
	#Collision Damage	
	ch_drawing.damage_flash(clamp(damage/750,.1,.95)) #hopefully no divide by zero
	ch_solidProperties.integrity_add(-damage)
	
	lastCollision = [local_collision_pos,local_collision_impulse,local_collision_normal]
	
	if polygon.area < MIN_BREAKABLE_SIZE:
		return
	
	#Weak (narrow) point fracture
	intersections = polygon.intersect_with_line(-local_collision_impulse+local_collision_pos,local_collision_pos+local_collision_impulse)

	if lastCollision[0] and lastCollision[1]:
		scaledDamage = damage*.5
		
		var intersecting_width = (lastCollision[1] - lastCollision[0]).length()
		if randf_range(0,scaledDamage*(ch_solidProperties.integrity/ch_solidProperties.max_integrity)) < intersecting_width:# * (1+2*(ch_solidProperties.integrity/ch_solidProperties.max_integrity)):
			return

		#print("Narrow")
		ch_solidProperties.integrity_add(-ch_solidProperties.integrity)

			
func split_asteroid():
		if not lastCollision:
			lastCollision = [polygon.points[0], polygon.centroid-polygon.points[0] ]
			
		var cutPolys = polygon.cut_along_line(lastCollision[0] , lastCollision[1])
		if len(cutPolys) <= 1:
			return

		var indices_to_cut_again = []
		
		if randf() < .5:
			indices_to_cut_again.append(0)
		if randf() < .5:
			indices_to_cut_again.append(1)
		
		var doubleCutPolys = []
		for i in range(len(cutPolys)):
			var c = cutPolys[i]
			if i not in indices_to_cut_again:
				doubleCutPolys = doubleCutPolys + [c]
				continue

			var cutC = c.cut_through_centroid(lastCollision[0])
			if len(cutC) <= 1:
				doubleCutPolys = doubleCutPolys + [c]
			else:
				doubleCutPolys = doubleCutPolys + cutC
		cutPolys = doubleCutPolys

		
		break_into_polylist(cutPolys)
		
		

func break_into_polylist(newPolys:Array):
	if len(newPolys) == 1:
		self.set_polygon(newPolys[0]) 
		'''TODO: Does this recalculate object center of mass???? I don't think so...'''
		return

	for np in newPolys:
		if np.area < MIN_PIECE_SIZE:
			continue
			
		var centroid = np.centroid
		np.center_area_centroid()
		
		var bodyTransform = Transform2D(rotation,position+centroid.rotated(rotation))
		var bodyAngularVelocity = angular_velocity
		var bodyVelocityAtPoint = linear_velocity
		bodyVelocityAtPoint += Vector2(centroid.y,-centroid.x) * bodyAngularVelocity
		var bodyVelocities = Transform2D(bodyAngularVelocity,bodyVelocityAtPoint)
		
		var bodyArgs = [bodyTransform,bodyVelocities]
		
		'''
		if inheritSolid:
			var newSolid = SolidSubstance.new()
			newSolid._set_substance(body.solid.substance)
			print("Setting new substance to " + body.solid.substance.substanceName)
			print("New substance set to " + newSolid.substance.substanceName)
			newSolid.heat.set_distributedHeat(body.solid.heat.get_total_heat())
			bodyArgs.append(newSolid)
		'''
	
		
		GlobalSignals.create_gameObj.emit(GlobalSignals.asteroid,[bodyArgs,np])
		
		queue_free()
	
'''
TODO:
	probability of break:
		proportional to impulse
		inversely proportional to thickness (to a limit)
		inversely proportional to durability
		proportional to hardness
		limited by integrity - low integrity -> high probability, high integrity -> low probability (inversely prop?)
	
		thickness - 1px to 1000s of px
		thickness_factor = clamp(thickness/500,0,1)
		impulse * hardness / (durability*integrity*thickness_factor)
		or smth
	
	1. Calculate scaled damage (scaling factor * impulse * other hardness/self durability)
	2. Pick a random value up to scaled damage. If this value is greater than the width of intersection, break.
	
todo:
	cut zigzag

'''


'''
func _draw():
	if not lastCollision:
		return
	var local_collision_pos = lastCollision[0]
	var local_collision_impulse:Vector2
	local_collision_impulse = lastCollision[1]
	#local_collision_normal
	
	draw_line(local_collision_pos,local_collision_pos+local_collision_impulse.normalized() * scaledDamage,Color.CYAN,2)

	for i in intersections:
		if not i:
			continue
		draw_circle(i,3,Color.PINK)

'''









'''HELPER FUNCTIONS'''


'''Rotates a direction vector to local coordinates'''
func rotate_to_local(vect:Vector2) -> Vector2:
	return to_local(vect + position)
	
'''Rotates a direction vector to global coordinates'''
func rotate_to_global(vect:Vector2) -> Vector2:
	return to_global(vect)- position
	











