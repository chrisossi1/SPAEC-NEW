extends Node


'''Solid Substances'''

const substanceProperties = {
	"color":null,
	"fill_color":null,
	
	"durability":null,
	"hardness":null,
	
	"density":null,
	
	"thermal_conductivity":null,
	"melting_heat_density":null
}

const numericalProperties = ["durability","hardness","density","thermal_conductivity","melting_heat_density"]
const colorProperties = ["color","fill_color"]

class Substance:
	var substanceName := "INIT"
	var properties := substanceProperties.duplicate()
	
	func _init(sName:String,density:float,durability:float,hardness:float,color:Color):
			
		#Visual Properties
		properties["color"] = color
		properties["fill_color"] = Color(Color.BLACK,.5)
		
		#Collision Properties
		properties["durability"] = durability #Collision damage RX multiplier
		properties["hardness"] = hardness #COllision damage TX multiplier
		
		#Physics Properties
		properties["density"] = density

		#Thermal Properties
		properties["thermal_conductivity"] = .05
		properties["melting_heat_density"] = 7.5 #Heat per unit mass needed for melting, equal to Melting Point * Specific Heat Capacity

		'''
		Melting point -> Temperature
		Melting heat density -> Melting heat per mass -> Melting point*C
		Temperature T -> Heat / (Mass*C)
		Heat capacity C -> Heat / (Temperature * mass)
		
		For simplicity, Latent heat of fusion = 0
		'''

		
'''
	func copy():
		var new = Substance.new(substanceName,density,durability,hardness,color)
		new.thermal_conductivity = thermal_conductivity
		new.melting_heat_density = melting_heat_density
		return new
'''



'''Combines properties of the components of a composition of substances into a single set of properties'''
func composition_properties(composition:Dictionary) -> Dictionary:
	var ratioTotal := 0.
	var newProperties = substanceProperties.duplicate()
	for substance in composition.keys():
		var amount = composition[substance]
		#Sanity check
		assert(substance is Substance)
		assert(amount is float or amount is int)

		ratioTotal += amount

		for property in substance.properties.keys():
			if property in numericalProperties + colorProperties:
				if newProperties[property] == null:
					newProperties[property] = substance.properties[property]*amount	
				else:
					newProperties[property] += substance.properties[property]*amount
			else:
				print("Unk prop "+property)
				
	for property in newProperties.keys():
		if property in numericalProperties + colorProperties:
			newProperties[property] /= ratioTotal

	return newProperties










var unassigned := Substance.new("UNASSIGNED",1000,1000,0,Color.WHITE)

var rock:Substance
var rock_heavy:Substance

var ice:Substance

var ferrosteel:Substance
var ferrosteel_module:Substance



func _ready():
	
	rock = Substance.new("Rock",1,1,1,Color.DARK_GREEN)

	'''
	rock_heavy = rock.copy()
	rock_heavy.density *= 4
	rock_heavy.durability *= 2
	rock_heavy.color = Color.DARK_GREEN.darkened(.5)
	rock_heavy.fillColor = Color.BLACK
	'''
	
	
	ice = Substance.new("Ice",1,.25,.2,Color.LIGHT_BLUE)
	ice.properties["melting_heat_density"] = .5
	

	ferrosteel = Substance.new("Ferrosteel",1,1,1,Color.DEEP_SKY_BLUE)
	ferrosteel.properties["thermal_conductivity"] = .2
	ferrosteel.properties["melting_heat_density"] = 5.






'''Fluid Substances'''



























'''Energies'''

class Energy:
	var energyName := "INIT"

	func _init(eName:String):
		energyName = eName

	func copy():
		return Energy.new(energyName)


var laser = Energy.new("Laser")
var cryoLaser = Energy.new("CryoLaser")
var bullet = Energy.new("Bullet")
