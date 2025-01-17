extends Sprite2D

#Get camera
@onready var camera: Camera2D = get_parent().get_node("StageCamera")

#Get sprites
@onready var space: Sprite2D = $Space
@onready var space2: Sprite2D = $Space2
@onready var space3: Sprite2D = $Space3
@onready var space4: Sprite2D = $Space4
@onready var moon: Sprite2D = $Moon
@onready var earth: Sprite2D = $Earth

#Position variables
var spaceX = 0
var space2X = 0
var space3X = 0
var space4X = 0
var moonX = 0
var earthY = 0

#Timer
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += 1
	spaceX += .1
	space2X += .1
	space3X += .2
	space4X += .2
	moonX += .0158125
	
	if timer > 1 and (timer-1)%6360 == 0:
		spaceX += -670
		space2X += -670
		
	if timer > 1 and (timer-1)%3180 == 0:
		space3X += -670
		space4X += -670
		
	if (timer-1)%22784 < 11392:
		earthY += -.0058125
	else:
		earthY += .0058125
		
	space.global_position.x = spaceX + camera.global_position.x * 1
	space2.global_position.x = space2X + camera.global_position.x * 1
	space3.global_position.x = space3X + camera.global_position.x * .375
	space4.global_position.x = space4X + camera.global_position.x * .375
	moon.global_position.x = moonX + camera.global_position.x * .375
	earth.global_position.x = camera.global_position.x * .73
	earth.global_position.y = 240 + earthY
