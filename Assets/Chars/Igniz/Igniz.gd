extends CharacterBody2D

const SPEED = 150.0

#DATA
const LIFE = 1000
const POWER = 6000
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
#S = Stand, C = Crouch, A = Air, L = Lying
var STATETYPE = "S"
#I = Idle, A = Attack, H = Being Hit
var MOVETYPE = "I"
#S = Stand, C = Crouch, A = Air, N = None
var PHYSICS = "S"

#Variable for check the character is in controlable or not
var CTRL = true

#GET DATA FROM PARENT (Player1 / Player2)
@onready var TEAMSIDE
@onready var FACING

#GET OPPONENT (Player1 / Player2)
@onready var P2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var push_box: CollisionShape2D = $PushBox
@onready var hurt_box: CollisionShape2D = $StaticBody2D.get_node("HurtBox")

#ANIMATION RELATED
#Record current animation, animation frames left, current frames
var ANIM
var ANIMTIME
var ANIMCOUNT

#JUMPING SYSTEM
var JUMP_DIRECTION
var LONG_JUMP
var RUN_JUMP

#VELOCITY KEEP
var VEL

#DISTANCE RELATED
var P2DIST_X
var P2BODYDIST_X
var P2DIST_Y

#STATENO AND TIME IN STATE RECORD
var STATENO
var PREVSTATENO
var TIME = 0

#NOT HIT BY ([["SCA"], ["NSH"], ["NSH"], ["NSH"]])
#Note: [STATETYPE, ATTACK, THROW, PROJECTILE]
var NOTHITBY: Array

#HIT RECORD
var MOVECONTACT
var HITCOUNT
var HITSHAKETIME

#HIT DEFINITION
var PRIORITY: int
var ATTR: Array
var ANIMTYPE: String
var DAMAGE: Array
var GETPOWER: Array
var GIVEPOWER: Array
var HITFLAG: String
var GUARDFLAG: String
var PAUSETIME: Array
var GUARDPAUSETIME: Array
var HITSPARK: String
var GUARDSPARK: String
var SPARKXY: Vector2
var HITTIME: int
var GROUNDTYPE: String
var GROUNDVELOCITY: Vector2
var AIRTYPE: String
var AIRVELOCITY: Vector2
var AIRFALL: bool
var FALL: bool
var YACCEL: Vector2
var PALFXTIME: int
var PALFXMUL: Vector3
var PALFXADD: Vector3
var PALFXSINADD: Vector3
var PALFXINVERTALL: bool
var PALFXCOLOR: int

#GET HIT RECORD
var GHVANIMTYPE
var GHVDAMAGE
var GHVPAUSETIME
var GHVHITTIME
var GHVTYPE
var GHVVELOCITY
var GHVFALL
var GHVYACCEL
var GHVPALFXTIMER: int = 0
var GHVPALFXTIME: int = 0
var GHVPALFXADD = Vector3(0,0,0)
var GHVPALFXMUL = Vector3(256,256,256)
var GHVPALFXSINADD = Vector4(0,0,0,1)
var GHVPALFXCOLOR = 256
var GHVPALFXINVERTALL = false

#INPUT HISTORY
var INPUT = []
var INPUT_TIMER = 0
var INPUT_MAP = {
	#Player 1
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
	"Start": "s",
	#Player 2
	"Up2": "U",
	"Down2": "D",
	"Left2": "B",
	"Right2": "F",
	"A2": "a",
	"B2": "b",
	"C2": "c",
	"X2": "x",
	"Y2": "y",
	"Z2": "z",
	"Start2": "s"
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
	_state_control()

func _input_control() -> void:
	INPUT_TIMER += 1
	var key = ""
	
	if (FACING == 1 and P2DIST_X < 0) or (FACING == -1 and P2DIST_X>= 0):
		INPUT_MAP["Left"] = "F"
		INPUT_MAP["Right"] = "B"
	else:
		INPUT_MAP["Left"] = "B"
		INPUT_MAP["Right"] = "F"
		
	for input in INPUT_MAP:
		if Input.is_action_pressed(input):
			if TEAMSIDE == 1:
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
			else:
				if Input.get_axis("Up2", "Down2") and Input.get_axis("Left2", "Right2"):
					if input == "Up2" or input == "Down2" or input == "Left2" or input == "Right2":
						key = key+INPUT_MAP[input]
				elif Input.get_axis("Up2", "Down2") and input != "Left2" and input != "Right2":
					if input == "Up2" or input == "Down2":
						key = key+INPUT_MAP[input]
				elif Input.get_axis("Left2", "Right2") and input != "Up2" and input != "Down2":
					if input == "Left2" or input == "Right2":
						key = key+INPUT_MAP[input]
				if input == "A2" or input == "B2" or input == "C2" or input == "X2" or input == "Y2" or input == "Z2" or input == "Start2":
					if key == "":
						key = key+INPUT_MAP[input]
					else:
						key = key+" "+INPUT_MAP[input]
	if key == "" or TEAMSIDE == 2:
		key = "N"
	
	if INPUT.size() == 0 or INPUT[INPUT.size() - 1][0] != key:
		if INPUT.size() >= 60:
			INPUT.remove_at(0)
		INPUT.append([key, INPUT_TIMER, INPUT_TIMER])
	elif INPUT[INPUT.size() - 1][0] == key:
		INPUT[INPUT.size() - 1][2] = INPUT_TIMER
	#print(INPUT)
	
func _state_control() -> void:
	if anim_player.is_playing():
		ANIMCOUNT = int(ceil(anim_player.current_animation_position / (1/60.0) * 10)/10)
	TIME += 1
	
	if GHVPALFXTIME > 0 and GHVPALFXTIMER <= GHVPALFXTIME or GHVPALFXTIME == -1:
		sprite.material.set_shader_parameter("ColorScale", GHVPALFXCOLOR)
		sprite.material.set_shader_parameter("Time", GHVPALFXTIMER)
		sprite.material.set_shader_parameter("Add", GHVPALFXADD)
		sprite.material.set_shader_parameter("SinAdd", GHVPALFXSINADD)
		sprite.material.set_shader_parameter("Mul", GHVPALFXMUL)
		sprite.material.set_shader_parameter("InvertAll", GHVPALFXINVERTALL)
		GHVPALFXTIMER += 1
	else:
		GHVPALFXTIMER = 0
		GHVPALFXTIME = 0
		sprite.material.set_shader_parameter("ColorScale", 256)
		sprite.material.set_shader_parameter("Time", 0)
		sprite.material.set_shader_parameter("Add", Vector3(0,0,0))
		sprite.material.set_shader_parameter("SinAdd", Vector4(0,0,0,1))
		sprite.material.set_shader_parameter("Mul", Vector3(256,256,256))
		sprite.material.set_shader_parameter("InvertAll", false)
	#If the character is not controlable
	if not CTRL:
		pass
		#if STATENO == "Get_Hit_Ground":
		#	get_hit_ground()
	#Else If the character is controlable
	elif CTRL:
		pass
		#if STATETYPE == "S" or STATETYPE == "C":
		#	#Else If didn't press movement inputs
		#	if "N" in INPUT[INPUT.size()-1][0].rsplit():
		#		stand()
	#If is playing any animations
	if anim_player.is_playing():
		#Record current animation and animation frames left
		ANIM = anim_player.current_animation
		ANIMTIME = int(ceil(anim_player.get_animation(ANIM).length / (1/60.0) * 10)/10 - ceil(anim_player.current_animation_position / (1/60.0) * 10)/10)
		ANIMCOUNT = int(ceil(anim_player.current_animation_position / (1/60.0) * 10)/10)
	else:
		ANIMTIME = 0
		ANIMCOUNT = -1
		
	#Change facing when opponent is at the back
	if P2DIST_X < 0:
		FACING *= -1
	#Adjust character's facing
	if FACING == 1:
		sprite.flip_h = false
		sprite.offset = Vector2 (-129,-193)
	else:
		sprite.flip_h = true
		sprite.offset = Vector2 (-182,-193)
		
	#Changing PushingBox depends on STATETYPE
	if STATETYPE == "S" or STATETYPE == "L":
		push_box.shape.extents = Vector2(15, 40)
		push_box.position = Vector2(0, -40)
	elif STATETYPE == "C":
		push_box.shape.extents = Vector2(15, 35)
		push_box.position = Vector2(0, -35)
	elif STATETYPE == "A":
		push_box.shape.extents = Vector2(15, 35)
		push_box.position = Vector2(0, -70)

func stand() -> void:
	if STATENO != "Stand":
		PREVSTATENO = STATENO
		STATENO = "Stand"
		TIME = 0
		STATETYPE = "S"
		MOVETYPE = "I"
		PHYSICS = "S"
	elif (ANIM != "Stand" and ANIM != "Turning" and ANIM != "Crouch_To_Stand") or ((ANIM == "Turning" or ANIM == "Crouch_To_Stand") and ANIMTIME == 0):
		anim_player.play("Stand")
	if ANIM == "Stand" or  ANIM == "Turning" or (ANIM == "Crouch_To_Stand" and ANIMTIME == 0):
		hurt_box.shape.extents = Vector2(17, 53)
		hurt_box.position = Vector2(0, -53)

func get_hit_ground() -> void:
	if STATENO != "Get_Hit_Ground":
		PREVSTATENO = STATENO
		STATENO = "Get_Hit_Ground"
		TIME = 0
		MOVETYPE = "H"
		CTRL = false
		z_index = 0
		
	if STATETYPE == "S":
		PHYSICS = "S"
	elif STATETYPE == "C":
		PHYSICS = "C"
		
	if STATETYPE == "S" and TIME == 0:
		if GHVTYPE == "High":
			if GHVANIMTYPE == "Light":
				anim_player.play("Get_Hit_Stand_High_Light")
			elif GHVANIMTYPE == "Medium":
				anim_player.play("Get_Hit_Stand_High_Medium")
			elif GHVANIMTYPE == "Hard":
				anim_player.play("Get_Hit_Stand_High_Hard")
		elif GHVTYPE == "Low":
			if GHVANIMTYPE == "Light":
				anim_player.play("Get_Hit_Stand_Low_Light")
			elif GHVANIMTYPE == "Medium":
				anim_player.play("Get_Hit_Stand_Low_Medium")
			elif GHVANIMTYPE == "Hard":
				anim_player.play("Get_Hit_Stand_Low_Hard")
	elif STATETYPE == "C" and TIME == 0:
		if GHVANIMTYPE == "Light":
			anim_player.play("Get_Hit_Crouch_Light")
		elif GHVANIMTYPE == "Medium":
			anim_player.play("Get_Hit_Crouch_Medium")
		elif GHVANIMTYPE == "Hard":
			anim_player.play("Get_Hit_Crouch_Hard")
		
	if TIME <= GHVPAUSETIME:
		anim_player.seek(0.0)
	elif TIME >= GHVPAUSETIME+GHVHITTIME:
		CTRL = true
		if STATETYPE == "S":
			stand()
		elif STATETYPE == "C":
			stand()
		
func get_hit_air() -> void:
	print(GHVANIMTYPE)
	print(GHVDAMAGE)
	print(GHVPAUSETIME)
	print(GHVHITTIME)
	print(GHVTYPE)
	print(GHVVELOCITY)
	print(GHVFALL)
	print(GHVYACCEL)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0
	
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

func _get_hit_check(CHITFLAG, CGUARDFLAG, CPRIORITY: int, CGHVATTR: Array, CGHVANIMTYPE, CGHVDAMAGE, CGETPOWER, CGHVPAUSETIME, CGHVHITTIME, CGHVGTYPE, CGHVGVELOCITY, CGHVATYPE, CGHVAVELOCITY, CGHVAFALL, CGHVFALL, CGHVYACCEL, CGHVPALFXTIME, CGHVPALFXADD, CGHVPALFXMUL, CGHVPALFXSINADD, CGHVPALFXCOLOR, CGHVPALFXINVERTALL) -> String:
	var check:bool = true
	var guard_check:bool = true
	
	var flag_checking:bool = false
	for flag in CHITFLAG.rsplit(""):
		if flag == "M":
			flag_checking = (STATETYPE == "S" or STATETYPE == "C")
		elif flag == "H":
			flag_checking = (STATETYPE == "S")
		elif flag == "L":
			flag_checking = (STATETYPE == "C")
		elif flag == "A":
			flag_checking = (STATETYPE == "A")
		elif flag == "F" and STATETYPE == "A" and MOVETYPE == "H":
			flag_checking = GHVFALL
		elif flag == "D":
			flag_checking = (STATETYPE == "L")
			
		if flag_checking:
			check = true
			break
		else:
			check = false
	
	var guardflag_checking:bool = false
	for flag in CGUARDFLAG.rsplit(""):
		if flag == "M":
			guardflag_checking = (STATETYPE == "S" or STATETYPE == "C")
		if flag == "H":
			guardflag_checking = (STATETYPE == "S")
		if flag == "L":
			guardflag_checking = (STATETYPE == "C")
		if flag == "A":
			guardflag_checking = (STATETYPE == "A")
			
		if guardflag_checking:
			guard_check = true
			break
		else:
			guard_check = false
	
	if CGHVATTR.size() > 0 and NOTHITBY.size() > 0 and check:
		var attr_check1 = true
		var attr_check2 = true
		var attr_check3 = true
		var attr_check4 = true
		if CGHVATTR.size() > 0:
			for state in CGHVATTR[0].rsplit(""):
				if NOTHITBY.size() > 0 and not state in NOTHITBY[0].rsplit(""):
					attr_check1 = false
		if CGHVATTR.size() > 0:
			for attr in CGHVATTR[1].rsplit(""):
				if NOTHITBY.size() > 0 and not attr in NOTHITBY[1].rsplit(""):
					attr_check2 = false
		if CGHVATTR.size() > 0:
			for attr in CGHVATTR[2].rsplit(""):
				if NOTHITBY.size() > 0 and not attr in NOTHITBY[2].rsplit(""):
					attr_check3 = false
		if CGHVATTR.size() > 0:
			for attr in CGHVATTR[3].rsplit(""):
				if NOTHITBY.size() > 0 and not attr in NOTHITBY[3].rsplit(""):
					attr_check4 = false
		if CGHVATTR[0] == "SCA":
			attr_check1 = false
		if CGHVATTR[1] == "NSH":
			attr_check2 = false
		if CGHVATTR[2] == "NSH":
			attr_check3 = false
		if CGHVATTR[3] == "NSH":
			attr_check4 = false
			
		if attr_check1 or(attr_check2 and attr_check3 and attr_check4):
			check = false
	
	if CPRIORITY < PRIORITY and check:
		check = false
	
	if check:
		if (STATETYPE == "S" or STATETYPE == "C") and not CGHVFALL:
			var System = get_node("/root/MainGame/System")
			GHVANIMTYPE = CGHVANIMTYPE
			GHVDAMAGE = CGHVDAMAGE[0]
			GHVPAUSETIME = CGHVPAUSETIME[1]+2
			GHVHITTIME = CGHVHITTIME
			GHVTYPE = CGHVGTYPE
			GHVVELOCITY = CGHVGVELOCITY
			GHVFALL = CGHVFALL
			GHVYACCEL = CGHVYACCEL
			GHVPALFXTIMER = 0
			GHVPALFXTIME = CGHVPALFXTIME
			GHVPALFXADD = CGHVPALFXADD
			GHVPALFXMUL = CGHVPALFXMUL
			GHVPALFXSINADD = CGHVPALFXSINADD
			GHVPALFXCOLOR = CGHVPALFXCOLOR
			GHVPALFXINVERTALL = CGHVPALFXINVERTALL
			TIME = 0
			get_hit_ground()
			if TEAMSIDE == 1:
				System.P1LifeCurrent -= GHVDAMAGE
				System.P1PowerCurrent += CGETPOWER[0]
			else:
				System.P2LifeCurrent -= GHVDAMAGE
				System.P2PowerCurrent += CGETPOWER[0]
				
			return "Hit"
		elif STATETYPE == "A" or (STATETYPE == "S" or STATETYPE == "C") and CGHVFALL:
			var System = get_node("/root/MainGame/System")
			GHVANIMTYPE = CGHVANIMTYPE
			GHVDAMAGE = CGHVDAMAGE[0]
			GHVPAUSETIME = CGHVPAUSETIME[1]+2
			GHVHITTIME = CGHVHITTIME
			GHVTYPE = CGHVATYPE
			GHVVELOCITY = CGHVAVELOCITY
			GHVPALFXTIMER = 0
			GHVPALFXTIME = CGHVPALFXTIME
			GHVPALFXADD = CGHVPALFXADD
			GHVPALFXMUL = CGHVPALFXMUL
			GHVPALFXSINADD = CGHVPALFXSINADD
			GHVPALFXCOLOR = CGHVPALFXCOLOR
			GHVPALFXINVERTALL = CGHVPALFXINVERTALL
			if CGHVFALL:
				GHVFALL = CGHVFALL
			else:
				GHVFALL = CGHVAFALL
			GHVYACCEL = CGHVYACCEL
			TIME = 0
			get_hit_air()
			if TEAMSIDE == 1:
				System.P1LifeCurrent -= GHVDAMAGE
				System.P1PowerCurrent += CGETPOWER[0]
			else:
				System.P2LifeCurrent -= GHVDAMAGE
				System.P2PowerCurrent += CGETPOWER[0]
			return "Hit"
			
	return "None"
