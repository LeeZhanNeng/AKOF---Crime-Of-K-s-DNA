extends CharacterBody2D

#DATA
const LIFE = 1000
const ATK = 100
const DEF = 100

#VELOCITY
#Note for any velocity related / with 60.0(delta) to get real PixelSPD/Frame
const WALK_FWD = 150.0#/60.0 = 2.5
const WALK_BACK = -150.0#/60.0 = -2.5
const JUMP_FWD = 192.0#/60.0 = 3.2
const JUMP_BACK = -186.0#/60.0 = -3.1
const JUMP_VELOCITY = -480.0#/60.0 = -8.0

#MOVEMENT
const GRAVITY = Vector2(0, 36.6)#/60.0 = (0,.61)
const STAND_FRICTION = .85
const CROUCH_FRICTION = .82

#BASIC STATEMENT
#S = Stand as 0, C = Crouch as 1, A = Air as 2, L = Lying as 3
enum STATETYPES {S, C, A, L}
#I = Idle as 0, A = Attack as 1, H = Being Hit as 2
enum MOVETYPES {I, A, H}
#S = Stand as 0, C = Crouch as 1, A = Air as 2
enum PHYSICAL {S, C, A}

#Variable for check the character is in controlable or not
var CTRL = true

#GET DATA FROM PARENT (Player1 / Player2)
@onready var TEAMSIDE
@onready var FACING

#GET OPPONENT (Player1 / Player2)
@onready var P2

#DEFAULT SETUP
var STATETYPE = STATETYPES.S
var MOVETYPE = MOVETYPES.I
var PHYSICS = PHYSICAL.S

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var push_box: CollisionShape2D = $PushBox
@onready var hurt_box: CollisionShape2D = $StaticBody2D.get_node("HurtBox")

#ANIMATION RELATED
#Record current animation and animation frames left
var ANIM
var ANIMTIME

#JUMPING SYSTEM
var JUMP_DIRECTION
var LONG_JUMP
var RUN_JUMP

#VELOCITY KEEP
var VEL

#DISTANCE RELATED
var P2DIST_X
var P2DIST_Y

#INPUT HISTORY
var INPUT = []
var INPUT_TIMER = 0
var INPUT_MAP = {
	"Up": "U",
	"Down": "D",
	"Left": "B",
	"Right": "F",
	"A": "a",
	"B": "b",
	"C": "c",
	"X": "x",
	"Y": "y",
	"Z": "z",
	"Start": "s"
}

func _ready() -> void:
	if get_parent()!= null:
		TEAMSIDE = get_parent().TEAMSIDE
		FACING = get_parent().FACING
		if get_parent().name == "Player1":
			P2 = get_node("/root/MainGame/Player2").get_child(0)
		else:
			P2 = get_node("/root/MainGame/Player1").get_child(0)

func _process(delta: float) -> void:
	P2DIST_X = FACING*(P2.position.x - position.x)
	P2DIST_Y = P2.position.y - position.y
	_input_control()
	_animation_control()

func _input_control() -> void:
	INPUT_TIMER += 1
	var key = ""
	for input in INPUT_MAP:
		if Input.is_action_pressed(input):
			if Input.get_axis("Up", "Down") and Input.get_axis("Left", "Right"):
				if input == "Up" or input == "Down" or input == "Left" or input == "Right":
					key = key+INPUT_MAP[input]
			elif Input.get_axis("Up", "Down") and input != "Left" and input != "Right":
				if input == "Up" or input == "Down":
					key = key+INPUT_MAP[input]
			elif Input.get_axis("Left", "Right") and input != "Up" and input != "Down":
				if input == "Left" or input == "Right":
					key = key+INPUT_MAP[input]
			if input == "A" or input == "B" or input == "C" or input == "X" or input == "Y" or input == "Z" or input == "Start":
				if key == "":
					key = key+INPUT_MAP[input]
				else:
					key = key+" "+INPUT_MAP[input]
	if key == "":
		key = "N"
	
	if INPUT.size() == 0 or INPUT[INPUT.size() - 1][0] != key:
		if INPUT.size() >= 60:
			INPUT.remove_at(0)
		INPUT.append([key, INPUT_TIMER, INPUT_TIMER])
	elif INPUT[INPUT.size() - 1][0] == key:
		INPUT[INPUT.size() - 1][2] = INPUT_TIMER
	
func _animation_control() -> void:
	#If the character is controlable and on floor
	if CTRL and(STATETYPE == 0 or STATETYPE == 1):
		#Change facing when opponent is at the back
		if P2DIST_X < 0:
			FACING *= -1
		#If didn't press movement inputs
		if not Input.get_axis("Up", "Down") and not Input.get_axis("Left", "Right"):
			#Set StateType and Physic to Standing
			STATETYPE = STATETYPES.S
			PHYSICS = PHYSICAL.S
			#If not in Turning animation and opponent is at the back
			if ANIM != "Turning" and P2DIST_X < 0:
				#Play Turning animation
				anim_player.play("Turning")
			#Else If just release Down button and not in Crouch_To_Stand animation
			elif ANIM == "Stand_To_Crouch" or ANIM == "Crouch":
				#Play Crouch_To_Stand animation
				anim_player.play("Crouch_To_Stand")
			#Else If not in Stand, Turning, Crouch_To_Stand animations or is in Crouch_To_Stand and finished playing animation
			elif (ANIM != "Stand" and ANIM != "Turning" and ANIM != "Crouch_To_Stand") or ((ANIM == "Turning" or ANIM == "Crouch_To_Stand") and ANIMTIME == 0):
				#Play Stand animation
				anim_player.play("Stand")
				
		#Else If pressing Up and not pressing Down
		elif Input.get_axis("Up", "Down") < 0:
			#Set StateType and Physic to Standing
			STATETYPE = STATETYPES.S
			PHYSICS = PHYSICAL.S
			#Reset velocity
			velocity = Vector2(0,0)
			#Get Jump's Direction
			JUMP_DIRECTION = FACING*Input.get_axis("Left", "Right")
			#Set the character is not controlable
			CTRL = false
			#Play Jump_Start animation
			anim_player.play("Jump_Start")
		
		#Else If pressing Down and not pressing Up
		elif Input.get_axis("Up", "Down") > 0:
			#Change StateType and Physic to Crouching
			STATETYPE = STATETYPES.C
			PHYSICS = PHYSICAL.C
			#If not in Turning_Crouch animation and opponent is at the back
			if ANIM != "Turning_Crouch" and P2DIST_X < 0:
				#Play Turning_Crouch animation
				anim_player.play("Turning_Crouch")
			#If not in Stand_To_Crouch, Crouch animations
			elif ANIM != "Stand_To_Crouch" and ANIM != "Crouch" and ANIM != "Turning_Crouch":
				#Play Stand_To_Crouch animation
				anim_player.play("Stand_To_Crouch")
			#Else If is in Stand_To_Crouch and finished playing animation
			elif (ANIM == "Turning_Crouch" or ANIM == "Stand_To_Crouch") and ANIMTIME == 0:
				#Play Crouch animation
				anim_player.play("Crouch")
			
		#Else If either pressing Left or Right
		elif Input.get_axis("Left", "Right"):
			#Set StateType and Physic to Standing
			STATETYPE = STATETYPES.S
			PHYSICS = PHYSICAL.S
			#If pressing Right
			if FACING*Input.get_axis("Left", "Right") > 0:
				#Play Walk Forward animation
				anim_player.play("Walk_Forward")
			#Else If pressing Left
			elif FACING*Input.get_axis("Left", "Right") < 0:
				#Play Walk Back animation
				anim_player.play("Walk_Backward")
				
	#Else not in controlable and on ground
	elif not CTRL and(STATETYPE == 0 or STATETYPE == 1):
		if ANIM == "Jump_Start":
			if Input.is_action_pressed("Up"):
				LONG_JUMP = true
			else:
				LONG_JUMP = false
			if ANIMTIME == 0:
				STATETYPE = STATETYPES.A
				if JUMP_DIRECTION == 0:
					velocity = Vector2(0,JUMP_VELOCITY + -120 * int(LONG_JUMP))
					anim_player.play("Jump_Neutral")
				elif JUMP_DIRECTION > 0:
					velocity = Vector2(JUMP_FWD,JUMP_VELOCITY + -120 * int(LONG_JUMP))
					anim_player.play("Jump_Forward")
				elif JUMP_DIRECTION < 0:
					velocity = Vector2(JUMP_BACK,JUMP_VELOCITY + -120 * int(LONG_JUMP))
					anim_player.play("Jump_Backward")
				CTRL = true
		elif ANIM == "Jump_Landing":
			CTRL = true
			
	if STATETYPE == 2:
		if ANIM == "Jump_Neutral" or ANIM == "Jump_Forward" or ANIM == "Jump_Backward":
			PHYSICS = PHYSICAL.A
		if VEL.y > 0 and position.y>= 0:
			CTRL = false
			STATETYPE = STATETYPES.S
			PHYSICS = PHYSICAL.S
			velocity = Vector2(0,0)
			position.y = 0;
			anim_player.play("Jump_Landing")
	
	#Adjust character's facing
	if FACING == 1:
		sprite.flip_h = false
		sprite.offset = Vector2 (-99,-175)
	else:
		sprite.flip_h = true
		sprite.offset = Vector2 (-136,-175)
	
	if FACING == 1 and (ANIM == "Turning" or ANIM == "Turning_Crouch"):
		sprite.flip_h = true
		sprite.offset = Vector2 (-136,-175)
	elif FACING == -1 and (ANIM == "Turning" or ANIM == "Turning_Crouch"):
		sprite.flip_h = false
		sprite.offset = Vector2 (-99,-175)
	
	#If is playing any animations
	if anim_player.is_playing():
		#Record current animation and animation frames left
		ANIM = anim_player.current_animation
		ANIMTIME = int(anim_player.get_animation(ANIM).length / (1/60.0) - anim_player.current_animation_position / (1/60.0))
	else:
		ANIMTIME = 0
		
	#Changing PushingBox depends on STATETYPE
	if STATETYPE == 0 or STATETYPE == 3:
		push_box.shape.extents = Vector2(15, 40)
		push_box.position = Vector2(0, -40)
	elif STATETYPE == 1:
		push_box.shape.extents = Vector2(15, 35)
		push_box.position = Vector2(0, -35)
	elif STATETYPE == 2:
		push_box.shape.extents = Vector2(15, 35)
		push_box.position = Vector2(0, -70)
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if PHYSICS == 2:
		velocity = VEL+GRAVITY# get_gravity() * delta
		
	#If is in Walk_Forward animation
	if ANIM == "Walk_Forward":
		#Walking Forward
		velocity.x = FACING*WALK_FWD
	#Else If is in Walk_Backward animation
	elif ANIM == "Walk_Backward":
		#Walking Backward
		velocity.x = FACING*WALK_BACK
	#Else If not both of them
	elif ANIM == "Jump_Forward" or ANIM == "Jump_Backward":
		if ANIM == "Jump_Forward":
			velocity.x = FACING*JUMP_FWD
		else:
			velocity.x = FACING*JUMP_BACK
	elif ANIM != "Jump_Neutral" and ANIM != "Jump_Forward" and ANIM != "Jump_Backward":
		velocity.y = 0
		if PHYSICS == 0:
			if (ANIM == "Stand" or ANIM == "Turning") and velocity.x*delta <= 2:
				velocity.x = 0
			velocity.x *= STAND_FRICTION
		if PHYSICS == 1:
			if ANIM == "Crouch" or ANIM == "Turning_Crouch":
				velocity.x = 0
			if ANIM == "Stand_To_Crouch" && ANIMTIME == 5:
				velocity.x *= .75
			velocity.x *= CROUCH_FRICTION
		
	VEL = velocity * Vector2 (FACING,1)
	
	move_and_slide()
	
	var triggering_control = 0
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var stageWallLeft = get_node("/root/MainGame/Stage").get_child(0).get_node("StaticBody2D/WallLeft")
		var stageWallRight = get_node("/root/MainGame/Stage").get_child(0).get_node("StaticBody2D/WallRight")
		var distWallLeft = stageWallLeft.global_position.x+stageWallLeft.shape.extents.x - global_position.x
		var distWallRight = stageWallRight.global_position.x-stageWallLeft.shape.extents.x - global_position.x
		if collider.is_in_group("Characters") and collider != self:
			var sizeX = get_node("PushBox").shape.extents.x
			var colliderSizeX = collider.get_node("PushBox").shape.extents.x
			var colliderDistX = FACING*(collider.global_position.x - global_position.x)
			var colliderBodyDistX
			if colliderDistX>= 0:
				colliderBodyDistX = colliderDistX-sizeX-colliderSizeX
			else:
				colliderBodyDistX = colliderDistX-sizeX+colliderSizeX
			if position.y-35 > -collider.get_node("PushBox").shape.extents.y*2 and VEL.x > collider.VEL.x:
				if (FACING == 1 and floor(distWallRight) > 15+sizeX+colliderSizeX+FACING*VEL.x*delta) or (FACING == -1 and ceil(distWallLeft) < -15-sizeX-colliderSizeX+FACING*VEL.x*delta):
					collider._get_collided_x(FACING*VEL, delta)
				elif (FACING == 1 and floor(distWallRight) <= 15+sizeX+colliderSizeX+FACING*VEL.x*delta) or (FACING == -1 and ceil(distWallLeft) >= -15-sizeX-colliderSizeX+FACING*VEL.x*delta):
					if ceil(collider.position.y) < 0:
						position.x -= FACING*VEL.x*delta*1.01
					else:
						position.x -= FACING*.05
			elif VEL.y >= 0:
				if triggering_control == 0 and floor(colliderDistX) >= 0:
					var P1Collided
					var P2Collided
					triggering_control = 1
					if (FACING == 1 and ceil(distWallLeft) >= -15-sizeX) or (FACING == -1 and floor(distWallRight) <= 15+sizeX):
						if ceil(distWallLeft) >= -15-sizeX:
							P1Collided = distWallLeft
						elif floor(distWallRight) <= 15+sizeX:
							P1Collided = distWallRight
						P2Collided = FACING*colliderBodyDistX
						_get_collided_y(Vector2 (P1Collided, VEL.y), delta)
						collider._get_collided_y(Vector2 (-P2Collided, 0), delta)
					else:
						_get_collided_y(Vector2 (FACING*((colliderBodyDistX-VEL.x*delta)-.05), VEL.y), delta)
				elif triggering_control == 0 and floor(colliderDistX) < 0:
					var P1Collided
					var P2Collided
					triggering_control = 1
					if (FACING == 1 and floor(distWallRight) <= 15) or (FACING == -1 and ceil(distWallLeft) >= -15):
						if ceil(distWallLeft) >= -15-sizeX:
							P1Collided = distWallLeft
						elif floor(distWallRight) <= 15+sizeX:
							P1Collided = distWallRight
						P2Collided = FACING*colliderBodyDistX
						_get_collided_y(Vector2 (-P1Collided, VEL.y), delta)
						collider._get_collided_y(Vector2 (P2Collided, 0), delta)
					else:
						_get_collided_y(Vector2 (FACING*(((sizeX*2+colliderBodyDistX)-VEL.x*delta)+.05), VEL.y), delta)
				else:
					if triggering_control >= 1 and triggering_control < 3:
						triggering_control += 1
					else:
						triggering_control = 0
		
func _get_collided_x(pushedValue: Vector2, delta: float) -> void:
	position.x = position.x + pushedValue.x/2.0*delta

func _get_collided_y(pushedValue: Vector2, delta: float) -> void:
	position.x = position.x + pushedValue.x
	if pushedValue.y == 0:
		position.y = 0
	elif pushedValue.y > 0:
		position.y += pushedValue.y*delta
		
	
