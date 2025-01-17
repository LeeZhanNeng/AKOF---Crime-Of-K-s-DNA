extends Camera2D

#Get P1 and P2
@onready var P1 = get_node("/root/MainGame/Player1").get_child(0)
@onready var P2 = get_node("/root/MainGame/Player2").get_child(0)

#Camera corner position
var LEFT_CORNER
var RIGHT_CORNER

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Set corner range
	LEFT_CORNER = global_position.x - get_viewport_rect().size.x * .5
	RIGHT_CORNER = global_position.x + get_viewport_rect().size.x * .5
	
	#Set the camera centered of both players for x-axis
	if (P1.global_position.x + P2.global_position.x) / 2.0 > get_limit(SIDE_LEFT) + get_viewport_rect().size.x * .5 and (P1.global_position.x + P2.global_position.x) / 2.0 < get_limit(SIDE_RIGHT) - get_viewport_rect().size.x * .5:
		global_position.x = (P1.global_position.x + P2.global_position.x) / 2.0
	elif (P1.global_position.x + P2.global_position.x) / 2.0 < get_limit(SIDE_LEFT) + get_viewport_rect().size.x * .5:
		global_position.x = get_limit(SIDE_LEFT) + get_viewport_rect().size.x * .5
	elif (P1.global_position.x + P2.global_position.x) / 2.0 > get_limit(SIDE_RIGHT) - get_viewport_rect().size.x * .5:
		global_position.x = get_limit(SIDE_RIGHT) - get_viewport_rect().size.x * .5
	
	#Set the camera for y-axis depends on highest y-axis player
	if P1.position.y < P2.position.y and get_limit(SIDE_TOP) < P1.position.y / 4.0:
		global_position.y = 120 + P1.position.y / 4.0
	elif P2.position.y < P1.position.y and get_limit(SIDE_TOP) < P2.position.y / 4.0:
		global_position.y = 120 + P2.position.y / 4.0
	elif get_limit(SIDE_TOP) >= P1.position.y / 4.0 or get_limit(SIDE_TOP) >= P2.position.y / 4.0:
		global_position.y = 120 + get_limit(SIDE_TOP)
	else:
		global_position.y = 120
	
	#When one player is in corner but other one not, push the one is in corner back to screen
	if LEFT_CORNER - P1.global_position.x >= -15 and RIGHT_CORNER - P2.global_position.x > 15:
		P1.global_position.x += 15 + (LEFT_CORNER - P1.global_position.x)
	elif RIGHT_CORNER - P1.global_position.x <= 15 and LEFT_CORNER - P2.global_position.x < -15:
		P1.global_position.x -= 15 - (RIGHT_CORNER - P1.global_position.x)
	elif LEFT_CORNER - P2.global_position.x >= -15 and RIGHT_CORNER - P1.global_position.x > 15:
		P2.global_position.x += 15 + (LEFT_CORNER - P2.global_position.x)
	elif RIGHT_CORNER - P2.global_position.x <= 15 and LEFT_CORNER - P1.global_position.x < -15:
		P2.global_position.x -= 15 - (RIGHT_CORNER - P2.global_position.x)
	
	#When both is in corner, push both of them back to screen
	if LEFT_CORNER - P1.global_position.x >= -15 and RIGHT_CORNER - P2.global_position.x <= 15:
		if P1.velocity.x < 0:
			P1.global_position.x -= P1.velocity.x*delta
		if P2.velocity.x > 0:
			P2.global_position.x -= P2.velocity.x*delta
	elif RIGHT_CORNER - P1.global_position.x <= 15 and LEFT_CORNER - P2.global_position.x >= -15:
		if P1.velocity.x > 0:
			P1.global_position.x -= P1.velocity.x*delta
		if P2.velocity.x < 0:
			P2.global_position.x -= P2.velocity.x*delta
			
