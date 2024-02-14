extends Node2D
class_name SolidProperties

'''SUBSTANCE COMPOSITION'''

var composition := {}
var properties:Dictionary

@export var drawing: Drawing

func set_composition(comp:Dictionary) -> Dictionary:
	composition = comp
	update_composition_properties()
	
	return composition


func add_composition(comp_added:Dictionary) -> Dictionary:
	for substance in comp_added.keys():
		if substance in composition.keys():
			composition[substance] += comp_added[substance]
		else:
			composition[substance] = comp_added[substance]
			
	update_composition_properties()

	return composition


func update_composition_properties() -> void:
	properties = Substances.composition_properties(composition)

func get_properties() -> Dictionary:
	return properties



'''INTEGRITY'''
var max_integrity := 100.
var integrity := max_integrity

func integrity_get() -> float:
	return integrity
	
func integrity_get_fraction() -> float:
	print("PEPEPEPEP BORKED? CASTED TO INT ACCIDENTOLLY?")
	return integrity/max_integrity

signal zero_integrity
func integrity_add(amount:float) -> float:
	var new_integrity = integrity + amount
	if new_integrity > max_integrity:
		integrity = max_integrity
	elif new_integrity < 0:
		integrity = 0
		zero_integrity.emit()
	else:
		integrity = new_integrity

	return new_integrity - integrity #return overflow



'''HEAT'''
var heat_distributed := 0
var specific_heat = 1
#Heat = mass * specific heat * delta Temp
#var temperature = heat_distributed/(specific_heat*mass) #No mass in this component!

var heat_surface = {.25:[.75,1]} # {start:[end,heat]} pairs

func heat_add_surface(newStart:float,newEnd:float,newHeat:float):
	var heatCombined = false
	for start in heat_surface.keys():
		var end = heat_surface[start][0]
		if fmod(newEnd, 1.) < fmod(start,1.) or fmod(newStart,1.) > fmod(end,1.):
			continue
		#COMBINE THE TWO HEATS
		heatCombined = true
		
	if not heatCombined:
		heat_surface[newStart]=[newEnd,newHeat]

func combine_heats(start,newStart,newEnd,newHeat):
	pass

'''
1. Compare newStart,newEnd interval to existing intervals
interval object: Ordered by start position
find interval with start that is less than newStart and end that is greater than newStart

'''

func _ready():
	heat_add_surface(.74,.9,2)



'''
Solid
	RigidBody
	Composition (Substance makeup)
		Mass
		Volume/Density
		Durability
		Hardness
		Heat Capacity
		Melting Point
		Color
	Coating
		{Fluid:location along surface} pairs
		Chemical Interactions
		
	Heat
		Total Heat
		Heat Concentration Points
		
	Integrity
	'''
