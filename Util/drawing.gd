'''
Drawing Component

child node of RigidBody so it inherits the transform

Responsibilities:
	Store and draw color and polygon	
	Add effects for hitflash, selection, hover highlight, 
	
	TODO:
		drawing shouldn't handle hover and stuff? Maybe just a thing for a draw modifier, or UI?
		
'''

extends Node2D
class_name Drawing

@export var solidProperties : SolidProperties

var poly:Polygon
var outlinePolys

const thickness = 4

func set_polygon(p:Polygon) -> void:
	poly = p
	outlinePolys = Geometry2D.offset_polygon(poly.points,-thickness/2,Geometry2D.JOIN_ROUND)
	for outlinePoly in outlinePolys:
		outlinePoly.append(outlinePoly[0])
		
		
var draw_colorOutline : Color
var draw_colorFill : Color
var draw_colorOutline_prev := draw_colorOutline
var draw_colorFill_prev := draw_colorFill
	
func _process(_delta):
	update_damage_flash()
	
	draw_colorOutline = solidProperties.properties["color"]
	draw_colorFill = solidProperties.properties["fill_color"]
	
	draw_colorOutline = Color.RED.lerp(draw_colorOutline,solidProperties.integrity/solidProperties.max_integrity)#solidProperties.integrity_get_fraction())
	draw_colorOutline = Color.WHITE.lerp(draw_colorOutline,damageFlashAmount)
	
	if draw_colorOutline != draw_colorOutline_prev or draw_colorFill != draw_colorFill_prev:	
		queue_redraw()
		
	draw_colorOutline_prev = draw_colorOutline
	draw_colorFill_prev = draw_colorFill
	
	
const damageFlashLength = 100
var damageTime : int
var damageFlashAmount:=1.
var damageFlashBrightness = 1.

func update_damage_flash():
	damageFlashAmount = 1
	var elapsed = Time.get_ticks_msec() - damageTime
	if elapsed > damageFlashLength:
		return
	damageFlashAmount = elapsed as float/damageFlashLength
	
	damageFlashAmount = 1-damageFlashAmount
	damageFlashAmount *= damageFlashBrightness
	damageFlashAmount = 1-damageFlashAmount

func damage_flash(brightness:float):
	damageTime = Time.get_ticks_msec()
	damageFlashBrightness = brightness
	
func _draw():
	draw_colored_polygon(poly.points,draw_colorFill)
	for outlinePoly in outlinePolys:
		draw_polyline(outlinePoly,draw_colorOutline,thickness,true)
