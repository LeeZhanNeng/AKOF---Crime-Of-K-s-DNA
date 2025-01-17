extends Node2D

#Get camera
@onready var camera: Camera2D = get_parent().get_node("Stage").get_child(0).get_node("StageCamera")

#Get Players
@onready var P1: CharacterBody2D = get_parent().get_node("Player1").get_child(0)
@onready var P2: CharacterBody2D = get_parent().get_node("Player2").get_child(0)

#Get Timer Node
@onready var TimerLabel: Label = $Timer.get_node("Label")

#Get Nodes for P1
@onready var P1Portrait: Sprite2D = $P1Life.get_node("Portrait")
@onready var P1Name: Label = $P1Life.get_node("Name")
@onready var P1Life: Sprite2D = $P1Life.get_node("Life")
@onready var P1LifeClip: Sprite2D = P1Life.get_node("LifeClip")
@onready var P1Damaged: Sprite2D = $P1Life.get_node("Damaged")
@onready var P1DamagedClip: AnimatedSprite2D = P1Damaged.get_node("DamagedClip")
@onready var P1Power: Sprite2D = $P1Power.get_node("Power")
@onready var P1PowerClip: Sprite2D = P1Power.get_node("PowerClip")
@onready var P1PowerLabel: Label = $P1Power.get_node("Label")

#Get Nodes for P2
@onready var P2Portrait: Sprite2D = $P2Life.get_node("Portrait")
@onready var P2Name: Label = $P2Life.get_node("Name")
@onready var P2Life: Sprite2D = $P2Life.get_node("Life")
@onready var P2LifeClip: Sprite2D = P2Life.get_node("LifeClip")
@onready var P2Damaged: Sprite2D = $P2Life.get_node("Damaged")
@onready var P2DamagedClip: AnimatedSprite2D = P2Damaged.get_node("DamagedClip")
@onready var P2Power: Sprite2D = $P2Power.get_node("Power")
@onready var P2PowerClip: Sprite2D = P2Power.get_node("PowerClip")
@onready var P2PowerLabel: Label = $P2Power.get_node("Label")

#Path
var path: String = "res://Assets/Chars/"

#Timer
var TimerCount = 0

#Get P1Data
var P1LifeMax
var P1LifeCurrent
var P1LifeScale = 1
var P1DamagedScale = 1
var P1DamagedScaleR = 1
var P1PowerMax
var P1PowerCurrent = 0
var P1PowerScale
var P1GHTimer = 20

#Get P2Data
var P2LifeMax
var P2LifeCurrent
var P2LifeScale = 1
var P2DamagedScale = 1
var P2DamagedScaleR = 1
var P2PowerMax
var P2PowerCurrent = 0
var P2PowerScale
var P2GHTimer = 20

func _ready() -> void:
	if has_node("/root/MenuBgm"):
		get_node("/root/MenuBgm").queue_free()
	
	P1Portrait.texture = load(path + P1.name + "/" + P1.name + ".png")
	P1Name.set_text(P1.name)
	
	P2Portrait.texture = load(path + P2.name + "/" + P2.name + ".png")
	P2Name.set_text(P2.name)
	
	P1LifeMax = P1.LIFE
	P1LifeCurrent = P1LifeMax
	P1PowerMax = P1.POWER
	
	P2LifeMax = P2.LIFE
	P2LifeCurrent = P2LifeMax
	P2PowerMax = P2.POWER
	
func _process(delta: float) -> void:
	if 99 - int(ceil(TimerCount * 100)/100) >= 0:
		TimerCount += 1 / 60.0
		TimerLabel.text = str(99 - int(ceil(TimerCount * 100)/100))
	else:
		TimerCount = 99
		TimerLabel.text = "0"
	
	global_position.x = camera.global_position.x
	global_position.y = camera.global_position.y - 120
	
	P1LifeScale = 1000 * P1LifeCurrent / P1LifeMax / 1000.0
	if P1PowerMax % 1000 == 0 and P1PowerCurrent == P1PowerMax:
		P1PowerScale = 1
	else:
		P1PowerScale = P1PowerCurrent % 1000 / 1000.0
	
	if P1.MOVETYPE == "H":
		P1GHTimer = 0
		P1DamagedScaleR = P1DamagedScale
	elif P1GHTimer < 20:
		P1GHTimer += 1
		P1DamagedScale = P1DamagedScaleR - (P1DamagedScaleR-P1LifeScale)*sin(2 * PI * 1/20.0/4 * P1GHTimer)
		if P1GHTimer == 20:
			P1DamagedScale = P1LifeScale
	
	if P2.MOVETYPE == "H":
		P2GHTimer = 0
		P2DamagedScaleR = P2DamagedScale
	elif P2GHTimer < 20:
		P2GHTimer += 1
		P2DamagedScale = P2DamagedScaleR - (P2DamagedScaleR-P2LifeScale)*sin(2 * PI * 1/20.0/4 * P2GHTimer)
		if P2GHTimer == 20:
			P2DamagedScale = P2LifeScale
	
	P2LifeScale = 1000 * P2LifeCurrent / P2LifeMax / 1000.0
	if P2PowerMax % 1000 == 0 and P2PowerCurrent == P2PowerMax:
		P2PowerScale = 1
	else:
		P2PowerScale = P2PowerCurrent % 1000 / 1000.0
	
	P1Life.scale.x = P1LifeScale
	P1LifeClip.scale.x = 1 / P1LifeScale
	P1Damaged.scale.x = P1DamagedScale
	P1DamagedClip.scale.x = 1 / P1DamagedScale
	P1Power.scale.x = P1PowerScale
	if P1PowerScale > 0:
		P1PowerClip.scale.x = 1 / P1PowerScale
	else:
		P1PowerClip.scale.x = 0
	P1PowerLabel.set_text(str(P1PowerCurrent / 1000))
	
	P2Life.scale.x = P2LifeScale
	P2LifeClip.scale.x = 1 / P2LifeScale
	P2Damaged.scale.x = P2DamagedScale
	P2DamagedClip.scale.x = 1 / P2DamagedScale
	P2Power.scale.x = P2PowerScale
	if P2PowerScale > 0:
		P2PowerClip.scale.x = 1 / P2PowerScale
	else:
		P2PowerClip.scale.x = 0
	P2PowerLabel.set_text(str(P2PowerCurrent / 1000))
	
