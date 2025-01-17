extends CharacterBody2D

#DATA
const LIFE = 1000
const POWER = 6000
const ATK = 100
const DEF = 100

#IN GAME USE
var CLIFE = LIFE
var CPOWER

#VELOCITY
#Note for any velocity related / with 60.0(delta) to get real PixelSPD/Frame
const WALK_FWD = 180.0#/60.0 = 3.0
const WALK_BACK = -180.0#/60.0 = -3.0
const RUN_FWD = 420#/60.0 = 7.0
const RUN_BACK = Vector2(-720,-180)#/60.0 = (-12,-3)
const JUMP_FWD = 192.0#/60.0 = 3.2
const JUMP_BACK = -192.0#/60.0 = -3.2
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

#NODES
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var push_box: CollisionShape2D = $PushBox
@onready var hurt_box: CollisionShape2D = $HurtBox.get_node("CollisionShape2D")
@onready var hit_box: CollisionShape2D = $HitBox.get_node("CollisionShape2D")
@onready var shapecast: ShapeCast2D = $HitBox.get_node("ShapeCast2D")
@onready var sfx_player: AudioStreamPlayer2D = $SFX
@onready var voice_player: AudioStreamPlayer2D = $Voice

@onready var System = get_node("/root/MainGame/System")

#ANIMATION RELATED
#Record current animation, animation frames left, current frames
var ANIM
var ANIMTIME
var ANIMCOUNT

#JUMPING SYSTEM
var JUMP_DIRECTION:int
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

#LOOPING SFX ID RECORDED
var RUN_SFX_ID: int

#NOT HIT BY ([["SCA"], ["NSH"], ["NSH"], ["NSH"]])
#Note: [STATETYPE, ATTACK, THROW, PROJECTILE]
var NOTHITBY

#HIT RECORD
var MOVECONTACT
var HITCOUNT
var HITSHAKETIME = -1
var ANIMCOUNTREMAIN

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
var HITSOUND: String
var GUARDSPARK: String
var GUARDSOUND: String
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
var PALFXADD: Vector3
var PALFXMUL: Vector3
var PALFXSINADD: Vector4
var PALFXCOLOR: int
var PALFXINVERTALL: bool

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

#MOVE LIST
var MOVESET = {
	#"NAME": "COMMAND set", "RELEASE first input to start trigger", "TIME(frames) to input command", "TRIGGERING OR NOT", "TRIGGER BUFFER", "BUFFER TIMER"
	"a": {"COMMAND": ["a"], "RELEASE": false, "TIME": 1, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"b": {"COMMAND": ["b"], "RELEASE": false, "TIME": 1, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"c": {"COMMAND": [["c"], ["b y"]], "RELEASE": false, "TIME": 1, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"x": {"COMMAND": ["x"], "RELEASE": false, "TIME": 1, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"y": {"COMMAND": ["y"], "RELEASE": false, "TIME": 1, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"z": {"COMMAND": [["z"], ["a x"]], "RELEASE": false, "TIME": 1, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"s": {"COMMAND": ["s"], "RELEASE": false, "TIME": 1, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Jump": {"COMMAND": [["D", "U"],["D", "UB"],["D", "UF"]], "RELEASE": true, "TIME": 12, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Run Forward": {"COMMAND": ["F", "F"], "RELEASE": true, "TIME": 10, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Backstep": {"COMMAND": ["B", "B"], "RELEASE": true, "TIME": 10, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Light Eine Trigger": {"COMMAND": ["D", "DF", "F", "x"], "RELEASE": true, "TIME": 15, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Heavy Eine Trigger": {"COMMAND": ["D", "DF", "F", "y"], "RELEASE": true, "TIME": 15, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Light Crow Bite": {"COMMAND": ["F", "D", "DF", "x"], "RELEASE": true, "TIME": 15, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Heavy Crow Bite": {"COMMAND": ["F", "D", "DF", "y"], "RELEASE": true, "TIME": 15, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Light Blackout": {"COMMAND": ["D", "DF", "F", "a"], "RELEASE": true, "TIME": 15, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Heavy Blackout": {"COMMAND": ["D", "DF", "F", "b"], "RELEASE": true, "TIME": 15, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Light Minute Spike": {"COMMAND": ["D", "DB", "B", "a"], "RELEASE": true, "TIME": 15, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Heavy Minute Spike": {"COMMAND": ["D", "DB", "B", "b"], "RELEASE": true, "TIME": 15, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Narrow Spike": {"COMMAND": [["D", "DB", "B", "a"], ["D", "DB", "B", "b"]], "RELEASE": true, "TIME": 15, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Light Heat Drive": {"COMMAND": ["D", "DF", "F", "D", "DF", "F", "x"], "RELEASE": true, "TIME": 25, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Heavy Heat Drive": {"COMMAND": ["D", "DF", "F", "D", "DF", "F", "y"], "RELEASE": true, "TIME": 25, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Light Chain Drive": {"COMMAND": ["D", "DF", "F", "DF", "D", "DB", "B", "x"], "RELEASE": true, "TIME": 30, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Heavy Chain Drive": {"COMMAND": ["D", "DF", "F", "DF", "D", "DB", "B", "y"], "RELEASE": true, "TIME": 30, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
	"Max Chain Drive": {"COMMAND": ["D", "DF", "F", "DF", "D", "DB", "B", "x y"], "RELEASE": true, "TIME": 30, "TRIGGERED": false, "BUFFER": 3, "TIMER": 0},
}

#CANCELS
var CANCEL = {
	"SPECIALS": ["Stand_Light_Punch_Far","Stand_Light_Punch_Close","Stand_Light_Kick_Close","Stand_Heavy_Punch_Far","Stand_Heavy_Punch_Close","Stand_Heavy_Kick_Close"],
	"SUPERS": [],
	"MAXS": [],
	"NEOMAXS": []
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
	if MOVETYPE == "I" or MOVETYPE == "H":
		MOVECONTACT = 0
		HITCOUNT = 0
	if MOVECONTACT > 0:
		MOVECONTACT += 1
	P2DIST_X = FACING*(P2.position.x - position.x)
	if P2DIST_X>= 0:
		P2BODYDIST_X = P2DIST_X-15-15
	else:
		P2BODYDIST_X = P2DIST_X-15+15
	P2DIST_Y = P2.position.y - position.y
	_input_control()
	_check_moves()
	_state_control()
	_hit_box_check()

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
	if key == "":
		key = "N"
	
	if INPUT.size() == 0 or INPUT[INPUT.size() - 1][0] != key:
		if INPUT.size() >= 60:
			INPUT.remove_at(0)
		INPUT.append([key, INPUT_TIMER, INPUT_TIMER])
	elif INPUT[INPUT.size() - 1][0] == key:
		INPUT[INPUT.size() - 1][2] = INPUT_TIMER
	#print(INPUT)
	
func _check_moves() -> void:
	for NAME in MOVESET:
		var INFO = MOVESET[NAME]
		var COMMAND = INFO["COMMAND"]
		var MULCOMMAND = COMMAND[0] is Array
		var TIME_WINDOWS = INFO["TIME"]
		var RELEASE = INFO["RELEASE"]
		
		if INFO["TRIGGERED"]:
			if INFO["TIMER"] < INFO["BUFFER"]:
				if HITSHAKETIME < 0:
					INFO["TIMER"] += 1
			elif INFO["TIMER"] >= INFO["BUFFER"]:
				INFO["TRIGGERED"] = false
				INFO["TIMER"] = 0
		
		if MULCOMMAND:
			for sequence in COMMAND:
				if _check_input_sequence(sequence, TIME_WINDOWS, RELEASE, NAME, INFO):
					INFO["TRIGGERED"] = true
					INFO["TIMER"] = 0
					break
		elif true:
			if _check_input_sequence(COMMAND, TIME_WINDOWS, RELEASE, NAME, INFO):
				INFO["TRIGGERED"] = true
				INFO["TIMER"] = 0
				
func _check_input_sequence(input_sequence: Array, time_window: int, release: bool, NAME: String, INFO: Dictionary) -> bool:
	var entry_checked = []
	var directions = ["U", "D", "B", "F", "UB", "UF", "DB", "DF"]
	
	#Remain for debugging purpose
	if false:
		print(NAME)
		print(INFO)
	
	for i in range(input_sequence.size() - 1, -1, -1):
		var input_command = input_sequence[i]
		
		if input_sequence.size() == 1 and INPUT[INPUT.size()-1][1] == INPUT_TIMER:
			if input_command in INPUT[INPUT.size()-1][0].rsplit(" "):
				entry_checked.append(INPUT.size()-1)
			break
		
		for j in range(INPUT.size() - 1, -1, -1):
			var split = INPUT[j][0].rsplit(" ")
			if input_command in split and INPUT.size() > 2:
				if j == input_sequence.size()-1 and INPUT[j][1] == INPUT_TIMER:
					entry_checked.append(j)
					break
				elif entry_checked.size() > 0 and j >= entry_checked[entry_checked.size()-1]:
					if i < input_sequence.size()-1 and input_sequence[i] == input_sequence[i+1]:
						continue
					elif j > entry_checked[entry_checked.size()-1]:
						continue
				elif entry_checked.size() > 0 and INPUT[entry_checked[0]][1] != INPUT_TIMER:
					return false
				elif INPUT[j][1+int(release)] < INPUT_TIMER-time_window:
					return false
				entry_checked.append(j)
				break
			
	if input_sequence[-1] in directions and INPUT.size() > 2:
		var direction_detect1 = input_sequence[-1] == INPUT[INPUT.size()-1][0].rsplit(" ")[0]
		var direction_detect2 = input_sequence[-1] == INPUT[INPUT.size()-2][0].rsplit(" ")[0]
		var direction_detect3 = input_sequence[-1] == INPUT[INPUT.size()-3][0].rsplit(" ")[0]
		if direction_detect1 and direction_detect2 and direction_detect3:
			return false
	if entry_checked.size() != input_sequence.size() or INPUT[entry_checked[0]][1] != INPUT_TIMER:
		return false
	else:
		return true

func _state_control() -> void:
	if STATENO != "Run_Forward" and RUN_SFX_ID:
		RUN_SFX_ID = sfx_player.stop_sfx(RUN_SFX_ID)
		
	if anim_player.is_playing():
		ANIMCOUNT = 1 + int(ceil(anim_player.current_animation_position / (1/60.0) * 10)/10)
		
	hit_box.shape.extents = Vector2(0,0)
	hit_box.position = Vector2(0,9999)
	shapecast.shape.extents = Vector2(0,0)
	shapecast.position = Vector2(0,9999)
	
	if HITSHAKETIME < 0:
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
		
	if HITSHAKETIME>= 0:
		HITSHAKETIME -= 1
		MOVECONTACT -= 1
		anim_player.seek(ANIMCOUNTREMAIN/60.0)
	#If the character is not controlable
	elif not CTRL:
		if MOVESET["Light Eine Trigger"]["TRIGGERED"]:
			if STATENO in CANCEL["SPECIALS"] and MOVECONTACT:
				light_eine_trigger()
		elif MOVESET["Heavy Eine Trigger"]["TRIGGERED"]:
			if STATENO in CANCEL["SPECIALS"] and MOVECONTACT:
				heavy_eine_trigger()
		if STATENO == "Jump_Start":
			jump_start()
		elif STATENO == "Jump_Landing":
			CTRL = true
			jump_landing()
		elif STATENO == "Run_Forward":
			if "F" in INPUT[INPUT.size()-1][0].rsplit():
				run_forward()
			else:
				CTRL = true
				run_stop()
		elif STATENO == "Backstep":
			backstep()
		elif STATENO == "Backstep_Landing":
			backstep_landing()
		elif STATENO == "Stand_Light_Punch_Far":
			stand_light_punch_far()
		elif STATENO == "Stand_Light_Punch_Close":
			stand_light_punch_close()
		elif STATENO == "Stand_Light_Kick_Far":
			stand_light_kick_far()
		elif STATENO == "Stand_Light_Kick_Close":
			stand_light_kick_close()
		elif STATENO == "Stand_Heavy_Punch_Far":
			stand_heavy_punch_far()
		elif STATENO == "Stand_Heavy_Punch_Close":
			stand_heavy_punch_close()
		elif STATENO == "Stand_Heavy_Kick_Far":
			stand_heavy_kick_far()
		elif STATENO == "Stand_Heavy_Kick_Close":
			stand_heavy_kick_close()
		elif STATENO == "Evasion_Roll":
			stand_light_punch_far()
		elif STATENO == "Blowback_Attack":
			stand_light_punch_close()
		elif STATENO == "Light_Eine_Trigger":
			light_eine_trigger()
		elif STATENO == "Heavy_Eine_Trigger":
			heavy_eine_trigger()
		elif STATENO == "Second_Shoot":
			second_shoot()
	#Else If the character is controlable
	elif CTRL:
		if STATETYPE == "S" or STATETYPE == "C":
			#Change facing when opponent is at the back
			if P2DIST_X < 0:
				FACING *= -1
			if MOVESET["Light Eine Trigger"]["TRIGGERED"]:
				light_eine_trigger()
			elif MOVESET["Heavy Eine Trigger"]["TRIGGERED"]:
				heavy_eine_trigger()
			elif MOVESET["y"]["TRIGGERED"]:
				if P2BODYDIST_X <= 29:
					stand_heavy_punch_close()
				else:
					stand_heavy_punch_far()
			elif MOVESET["b"]["TRIGGERED"]:
				if P2BODYDIST_X <= 24:
					stand_heavy_kick_close()
				else:
					stand_heavy_kick_far()
			elif MOVESET["x"]["TRIGGERED"]:
				if P2BODYDIST_X <= 21:
					stand_light_punch_close()
				else:
					stand_light_punch_far()
			elif MOVESET["a"]["TRIGGERED"]:
				if P2BODYDIST_X <= 21:
					stand_light_kick_close()
				else:
					stand_light_kick_far()
			elif MOVESET["Run Forward"]["TRIGGERED"]:
				run_forward()
			elif MOVESET["Backstep"]["TRIGGERED"]:
				backstep()
			elif ANIM == "Run_Stop" and  "N" in INPUT[INPUT.size()-1][0].rsplit():
				run_stop()
			#Else If didn't press movement inputs
			elif "N" in INPUT[INPUT.size()-1][0].rsplit():
				if ANIM == "Jump_Landing":
					jump_landing()
				else:
					stand()
			#Else If pressing Up and not pressing Down
			elif "U" in INPUT[INPUT.size()-1][0].rsplit():
				jump_start()
			#Else If pressing Down and not pressing Up
			elif "D" in INPUT[INPUT.size()-1][0].rsplit():
				crouch()
			#Else If either pressing Left or Right
			elif "B" in INPUT[INPUT.size()-1][0].rsplit() or "F" in INPUT[INPUT.size()-1][0].rsplit():
				walking()
		elif STATETYPE == "A":
			if STATENO == "Jump":
				jump()
		
	#Adjust character's facing
	if FACING == 1:
		sprite.flip_h = false
		sprite.offset = Vector2 (-104,-143)
	else:
		sprite.flip_h = true
		sprite.offset = Vector2 (-121,-143)
	
	if FACING == 1 and (ANIM == "Turning" or ANIM == "Turning_Crouch"):
		sprite.flip_h = true
		sprite.offset = Vector2 (-121,-143)
	elif FACING == -1 and (ANIM == "Turning" or ANIM == "Turning_Crouch"):
		sprite.flip_h = false
		sprite.offset = Vector2 (-104,-143)
	
	#If is playing any animations
	if anim_player.is_playing():
		#Record current animation and animation frames left
		ANIM = anim_player.current_animation
		ANIMTIME = int(ceil(anim_player.get_animation(ANIM).length / (1/60.0) * 10)/10 - ceil(anim_player.current_animation_position / (1/60.0) * 10)/10)
		ANIMCOUNT = 1 + int(ceil(anim_player.current_animation_position / (1/60.0) * 10)/10)
	else:
		ANIMTIME = 0
		ANIMCOUNT = -1
		
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
	if ANIM != "Turning" and P2DIST_X < 0:
		anim_player.play("Turning")
	elif ANIM == "Stand_To_Crouch" or ANIM == "Crouch":
		TIME = 0
		anim_player.play("Crouch_To_Stand")
		ANIMCOUNT = 1
	elif (ANIM != "Stand" and ANIM != "Turning" and ANIM != "Crouch_To_Stand") or ((ANIM == "Turning" or ANIM == "Crouch_To_Stand") and ANIMTIME == 0):
		anim_player.play("Stand")
		ANIMCOUNT = 1
	if ANIM == "Stand_To_Crouch" or ANIM == "Crouch" or ANIM == "Crouch_To_Stand":
		if TIME <= 3:
			hurt_box.shape.extents = Vector2(17, 32+4*TIME)
			hurt_box.position = Vector2(0, -32-4*TIME)
	if ANIM == "Stand" or  ANIM == "Turning" or (ANIM == "Crouch_To_Stand" and ANIMTIME == 0):
		hurt_box.shape.extents = Vector2(17, 53)
		hurt_box.position = Vector2(0, -53)

func jump_start() -> void:
	if STATENO != "Jump_Start":
		PREVSTATENO = STATENO
		STATENO = "Jump_Start"
		TIME = 0
		STATETYPE = "S"
		MOVETYPE = "I"
		PHYSICS = "S"
		CTRL = false
	if ANIM != "Jump_Start":
		anim_player.play("Jump_Start")
		ANIMCOUNT = 1
	if ANIM != "Jump_Start" or ANIM == "Jump_Start":
		if TIME <= 1:
			hurt_box.shape.extents = Vector2(17, 46-4*TIME)
			hurt_box.position = Vector2(0, -46+4*TIME)
	if TIME == 0:
		velocity = Vector2(0,0)
		position.y = 0
		if "F" in INPUT[INPUT.size()-1][0].rsplit():
			JUMP_DIRECTION = 1
		elif "B" in INPUT[INPUT.size()-1][0].rsplit():
			JUMP_DIRECTION = -1
		else:
			JUMP_DIRECTION = 0
	if "U" in INPUT[INPUT.size()-1][0].rsplit():
		LONG_JUMP = true
	else:
		LONG_JUMP = false
	if PREVSTATENO == "Run_Forward":
		RUN_JUMP = true
	elif MOVESET["Jump"]["TRIGGERED"]:
		RUN_JUMP = true
	else:
		RUN_JUMP = false
	if ANIMTIME == 0:
		if JUMP_DIRECTION == 0:
			velocity = Vector2(FACING* 0 * (1 + .5 * int(RUN_JUMP)),JUMP_VELOCITY + -120 * int(LONG_JUMP))
		elif JUMP_DIRECTION > 0:
			velocity = Vector2(FACING*JUMP_FWD * (1 + .5 * int(RUN_JUMP)),JUMP_VELOCITY + -120 * int(LONG_JUMP))
		elif JUMP_DIRECTION < 0:
			velocity = Vector2(FACING*JUMP_BACK * (1 + .5 * int(RUN_JUMP)),JUMP_VELOCITY + -120 * int(LONG_JUMP))
		jump()

func jump() -> void:
	if STATENO != "Jump":
		PREVSTATENO = STATENO
		STATENO = "Jump"
		TIME = 0
		STATETYPE = "A"
		MOVETYPE = "I"
		PHYSICS = "A"
		CTRL = true
		if RUN_JUMP:
			sfx_player.play_sfx("Long_Jump")
		else:
			sfx_player.play_sfx("Jump")
	if JUMP_DIRECTION == 0 and ANIM != "Jump_Neutral":
		anim_player.play("Jump_Neutral")
		ANIMCOUNT = 1
	elif JUMP_DIRECTION > 0 and ANIM != "Jump_Forward":
		anim_player.play("Jump_Forward")
		ANIMCOUNT = 1
	elif JUMP_DIRECTION < 0 and ANIM != "Jump_Backward":
		anim_player.play("Jump_Backward")
		ANIMCOUNT = 1
	if ANIM == "Jump_Neutral":
		velocity.x = FACING* 0 * (1 + .5 * int(RUN_JUMP))
	elif ANIM == "Jump_Forward":
		velocity.x = FACING*JUMP_FWD * (1 + .5 * int(RUN_JUMP))
	elif ANIM == "Jump_Backward":
		velocity.x = FACING*JUMP_BACK * (1 + .5 * int(RUN_JUMP))
	if VEL.y > 0 and position.y>= 0:
		CTRL = false
		jump_landing()
	hurt_box.shape.extents = Vector2(17, 30)
	hurt_box.position = Vector2(0, -70)

func jump_landing() -> void:
	if STATENO != "Jump_Landing":
		PREVSTATENO = STATENO
		STATENO = "Jump_Landing"
		TIME = 0
		STATETYPE = "S"
		MOVETYPE = "I"
		PHYSICS = "S"
		sfx_player.play_sfx("Jump_Landing")
	velocity = Vector2(0,0)
	position.y = 0;
	if ANIM != "Jump_Landing":
		anim_player.play("Jump_Landing")
		ANIMCOUNT = 1
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 44)
	hurt_box.position = Vector2(0, -44)

func crouch() -> void:
	if STATENO != "Crouch":
		PREVSTATENO = STATENO
		STATENO = "Crouch"
		TIME = 0
		STATETYPE = "C"
		MOVETYPE = "I"
		PHYSICS = "C"
	if ANIM != "Turning_Crouch" and P2DIST_X < 0:
		anim_player.play("Turning_Crouch")
		ANIMCOUNT = 1
	elif ANIM != "Stand_To_Crouch" and ANIM != "Crouch" and ANIM != "Turning_Crouch":
		TIME = 0
		anim_player.play("Stand_To_Crouch")
		ANIMCOUNT = 1
	elif (ANIM == "Turning_Crouch" or ANIM == "Stand_To_Crouch") and ANIMTIME == 0:
		TIME = 0
		anim_player.play("Crouch")
		ANIMCOUNT = 1
	if ANIM != "Stand_To_Crouch" and ANIM != "Crouch" and ANIM != "Turning_Crouch" or ANIM == "Stand_To_Crouch":
		if TIME <= 3:
			hurt_box.shape.extents = Vector2(17, 48-4*TIME)
			hurt_box.position = Vector2(0, -48+4*TIME)
	if ANIM == "Crouch" or  ANIM == "Turning_Crouch":
		hurt_box.shape.extents = Vector2(17, 32)
		hurt_box.position = Vector2(0, -32)

func walking() -> void:
	if STATENO != "Walking":
		PREVSTATENO = STATENO
		STATENO = "Walking"
		TIME = 0
		STATETYPE = "S"
		MOVETYPE = "I"
		PHYSICS = "S"
	if "F" in INPUT[INPUT.size()-1][0].rsplit():
		anim_player.play("Walk_Forward")
		ANIMCOUNT = 1
		velocity.x = FACING*WALK_FWD
	elif "B" in INPUT[INPUT.size()-1][0].rsplit():
		anim_player.play("Walk_Backward")
		ANIMCOUNT = 1
		velocity.x = FACING*WALK_BACK
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func run_forward() -> void:
	if STATENO != "Run_Forward":
		PREVSTATENO = STATENO
		STATENO = "Run_Forward"
		TIME = 0
		STATETYPE = "S"
		MOVETYPE = "I"
		PHYSICS = "S"
		CTRL = false
	if ANIMTIME == 0:
		anim_player.play("Run_Forward")
		anim_player.seek(3/60.0, true, true)
	if "U" in INPUT[INPUT.size()-1][0].rsplit():
		jump_start()
	if ANIM != "Run_Forward":
		anim_player.play("Run_Forward")
		ANIMCOUNT = 1
	if ANIMCOUNT >= 3:
		velocity = FACING*Vector2(RUN_FWD, 0)
	if TIME == 3:
		RUN_SFX_ID = sfx_player.play_sfx("Run_Forward")
	hurt_box.shape.extents = Vector2(22, 44)
	hurt_box.position = Vector2(FACING*5, -44)
		
func run_stop() -> void:
	if STATENO != "Run_Stop":
		PREVSTATENO = STATENO
		STATENO = "Run_Stop"
		TIME = 0
		STATETYPE = "S"
		MOVETYPE = "I"
		PHYSICS = "S"
		CTRL = true
		RUN_SFX_ID = sfx_player.stop_sfx(RUN_SFX_ID)
	velocity = Vector2(0,0)
	if ANIM != "Run_Stop":
		anim_player.play("Run_Stop")
		ANIMCOUNT = 1
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 44)
	hurt_box.position = Vector2(0, -44)
	
func backstep() -> void:
	if STATENO != "Backstep":
		PREVSTATENO = STATENO
		STATENO = "Backstep"
		TIME = 0
		STATETYPE = "S"
		MOVETYPE = "I"
		PHYSICS = "S"
		CTRL = false
	if ANIM != "Backstep":
		anim_player.play("Backstep")
		ANIMCOUNT = 1
	if TIME == 0:
		velocity = Vector2(0,0)
		position.y = 0
		hurt_box.shape.extents = Vector2(17, 44)
		hurt_box.position = Vector2(0, -44)
	if ANIMCOUNT > 4:
		STATETYPE = "A"
		velocity.x *= .9
		velocity.y += GRAVITY.y
	if ANIMCOUNT == 4:
		velocity = Vector2(FACING,1)*RUN_BACK
		hurt_box.shape.extents = Vector2(17, 42)
		hurt_box.position = Vector2(0, -62)
		sfx_player.play_sfx("Backstep")
	if (ANIMCOUNT > 4 or ANIMCOUNT == -1) and VEL.y > 0 and position.y>= 0:
		backstep_landing()

func backstep_landing() -> void:
	if STATENO != "Backstep_Landing":
		PREVSTATENO = STATENO
		STATENO = "Backstep_Landing"
		STATETYPE = "S"
		MOVETYPE = "I"
		PHYSICS = "S"
		CTRL = false
		sfx_player.play_sfx("Jump_Landing")
	velocity = Vector2(0,0)
	position.y = 0;
	if ANIM != "Backstep_Landing":
		anim_player.play("Backstep_Landing")
		ANIMCOUNT = 1
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func stand_light_punch_far() -> void:
	if STATENO != "Stand_Light_Punch_Far":
		PREVSTATENO = STATENO
		STATENO = "Stand_Light_Punch_Far"
		STATETYPE = "S"
		MOVETYPE = "A"
		PHYSICS = "S"
		CTRL = false
		velocity = Vector2(0,0)
	if ANIM != "Stand_Light_Punch_Far":
		anim_player.play("Stand_Light_Punch_Far")
		ANIMCOUNT = 1
	if ANIM == "Stand_Light_Punch_Far":
		if ANIMCOUNT == 1 and randi_range(0,1) == 0:
			voice_player.play_voice("res://Assets/Chars/K'/Sounds/K'_10-0.wav")
		if ANIMCOUNT == 4:
			sfx_player.play_sfx("LP_Whiff")
		if ANIMCOUNT >= 4 and ANIMCOUNT < 7:
			PRIORITY = 3
			ATTR = [STATETYPE,"N","",""]
			ANIMTYPE = "Light"
			DAMAGE = [25, 0]
			GETPOWER = [25,25]
			GIVEPOWER = [8,8]
			HITFLAG = "MAF"
			GUARDFLAG = "MA"
			PAUSETIME = [7,7]
			HITSPARK = "Hit_Light"
			HITSOUND = "LP_Hit"
			GUARDSPARK = "Guard_Light"
			GUARDSOUND = "Guard_Light"
			SPARKXY = Vector2(-10,-85)
			HITTIME = 9
			GROUNDTYPE = "High"
			GROUNDVELOCITY = Vector2(-360,0)
			AIRTYPE = "High"
			AIRVELOCITY = Vector2(-270,-390)
			AIRFALL = true
			FALL = false
			YACCEL = Vector2(0,30)
			
			hit_box.shape.extents = Vector2(24,12)
			hit_box.position = Vector2(FACING*46,-84)
			shapecast.shape.extents = Vector2(24,12)
			shapecast.position = Vector2(FACING*46,-84)
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func stand_light_punch_close() -> void:
	if STATENO != "Stand_Light_Punch_Close":
		PREVSTATENO = STATENO
		STATENO = "Stand_Light_Punch_Close"
		STATETYPE = "S"
		MOVETYPE = "A"
		PHYSICS = "S"
		CTRL = false
		velocity = Vector2(0,0)
	if ANIM != "Stand_Light_Punch_Close":
		anim_player.play("Stand_Light_Punch_Close")
		ANIMCOUNT = 1
	if ANIM == "Stand_Light_Punch_Close":
		if ANIMCOUNT == 1 and randi_range(0,1) == 0:
			voice_player.play_voice("res://Assets/Chars/K'/Sounds/K'_10-0.wav")
		if ANIMCOUNT == 4:
			sfx_player.play_sfx("LP_Whiff")
		if ANIMCOUNT >= 4 and ANIMCOUNT < 7:
			PRIORITY = 3
			ATTR = [STATETYPE,"N","",""]
			ANIMTYPE = "Light"
			DAMAGE = [25, 0]
			GETPOWER = [25,25]
			GIVEPOWER = [8,8]
			HITFLAG = "MAF"
			GUARDFLAG = "MA"
			PAUSETIME = [7,7]
			HITSPARK = "Hit_Light"
			HITSOUND = "LP_Hit"
			GUARDSPARK = "Guard_Light"
			GUARDSOUND = "Guard_Light"
			SPARKXY = Vector2(-10,-85)
			HITTIME = 9
			GROUNDTYPE = "High"
			GROUNDVELOCITY = Vector2(-360,0)
			AIRTYPE = "High"
			AIRVELOCITY = Vector2(-270,-390)
			AIRFALL = true
			FALL = false
			YACCEL = Vector2(0,30)
			
			hit_box.shape.extents = Vector2(20,12)
			hit_box.position = Vector2(FACING*26,-74)
			shapecast.shape.extents = Vector2(20,12)
			shapecast.position = Vector2(FACING*26,-74)
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func stand_light_kick_far() -> void:
	if STATENO != "Stand_Light_Kick_Far":
		PREVSTATENO = STATENO
		STATENO = "Stand_Light_Kick_Far"
		STATETYPE = "S"
		MOVETYPE = "A"
		PHYSICS = "S"
		CTRL = false
		velocity = Vector2(0,0)
	if ANIM != "Stand_Light_Kick_Far":
		anim_player.play("Stand_Light_Kick_Far")
		ANIMCOUNT = 1
	if ANIM == "Stand_Light_Kick_Far":
		if ANIMCOUNT == 1 and randi_range(0,1) == 0:
			voice_player.play_voice("res://Assets/Chars/K'/Sounds/K'_10-0.wav")
		if ANIMCOUNT == 3:
			sfx_player.play_sfx("LK_Whiff")
		if ANIMCOUNT >= 7 and ANIMCOUNT < 10:
			PRIORITY = 3
			ATTR = [STATETYPE,"N","",""]
			ANIMTYPE = "Light"
			DAMAGE = [25, 0]
			GETPOWER = [25,25]
			GIVEPOWER = [8,8]
			HITFLAG = "MAF"
			GUARDFLAG = "MA"
			PAUSETIME = [7,7]
			HITSPARK = "Hit_Light"
			HITSOUND = "LK_Hit"
			GUARDSPARK = "Guard_Light"
			GUARDSOUND = "Guard_Light"
			SPARKXY = Vector2(-20,-55)
			HITTIME = 9
			GROUNDTYPE = "Low"
			GROUNDVELOCITY = Vector2(-360,0)
			AIRTYPE = "High"
			AIRVELOCITY = Vector2(-270,-390)
			AIRFALL = true
			FALL = false
			YACCEL = Vector2(0,30)
			
			hit_box.shape.extents = Vector2(22,16)
			hit_box.position = Vector2(FACING*62,-36)
			shapecast.shape.extents = Vector2(22,16)
			shapecast.position = Vector2(FACING*62,-36)
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func stand_light_kick_close() -> void:
	if STATENO != "Stand_Light_Kick_Close":
		PREVSTATENO = STATENO
		STATENO = "Stand_Light_Kick_Close"
		STATETYPE = "S"
		MOVETYPE = "A"
		PHYSICS = "S"
		CTRL = false
		velocity = Vector2(0,0)
	if ANIM != "Stand_Light_Kick_Close":
		anim_player.play("Stand_Light_Kick_Close")
		ANIMCOUNT = 1
	if ANIM == "Stand_Light_Kick_Close":
		if ANIMCOUNT == 1 and randi_range(0,1) == 0:
			voice_player.play_voice("res://Assets/Chars/K'/Sounds/K'_10-0.wav")
		if ANIMCOUNT == 6:
			sfx_player.play_sfx("LK_Whiff")
		if ANIMCOUNT >= 6 and ANIMCOUNT < 9:
			PRIORITY = 3
			ATTR = [STATETYPE,"N","",""]
			ANIMTYPE = "Light"
			DAMAGE = [25, 0]
			GETPOWER = [25,25]
			GIVEPOWER = [8,8]
			HITFLAG = "MAF"
			GUARDFLAG = "MA"
			PAUSETIME = [7,7]
			HITSPARK = "Hit_Light"
			HITSOUND = "LK_Hit"
			GUARDSPARK = "Guard_Light"
			GUARDSOUND = "Guard_Light"
			SPARKXY = Vector2(-15,-20)
			HITTIME = 9
			GROUNDTYPE = "Low"
			GROUNDVELOCITY = Vector2(-360,0)
			AIRTYPE = "High"
			AIRVELOCITY = Vector2(-270,-390)
			AIRFALL = true
			FALL = false
			YACCEL = Vector2(0,30)
			
			hit_box.shape.extents = Vector2(24,12)
			hit_box.position = Vector2(FACING*26,-27)
			shapecast.shape.extents = Vector2(24,12)
			shapecast.position = Vector2(FACING*26,-27)
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func stand_heavy_punch_far() -> void:
	if STATENO != "Stand_Heavy_Punch_Far":
		PREVSTATENO = STATENO
		STATENO = "Stand_Heavy_Punch_Far"
		STATETYPE = "S"
		MOVETYPE = "A"
		PHYSICS = "S"
		CTRL = false
		velocity = Vector2(0,0)
	if ANIM != "Stand_Heavy_Punch_Far":
		anim_player.play("Stand_Heavy_Punch_Far")
		ANIMCOUNT = 1
	if ANIM == "Stand_Heavy_Punch_Far":
		if ANIMCOUNT == 1 and randi_range(0,1) == 0:
			voice_player.play_voice("res://Assets/Chars/K'/Sounds/K'_10-1.wav")
		if ANIMCOUNT == 12:
			sfx_player.play_sfx("HP_Whiff")
		if ANIMCOUNT >= 12 and ANIMCOUNT < 18:
			PRIORITY = 3
			ATTR = [STATETYPE,"N","",""]
			ANIMTYPE = "Hard"
			DAMAGE = [88, 0]
			GETPOWER = [53,53]
			GIVEPOWER = [8,8]
			HITFLAG = "MAF"
			GUARDFLAG = "MA"
			PAUSETIME = [11,11]
			HITSPARK = "Hit_Hard"
			HITSOUND = "HP_Hit"
			GUARDSPARK = "Guard_Hard"
			GUARDSOUND = "Guard_Hard"
			SPARKXY = Vector2(-10,-85)
			HITTIME = 17
			GROUNDTYPE = "High"
			GROUNDVELOCITY = Vector2(-360,0)
			AIRTYPE = "High"
			AIRVELOCITY = Vector2(-270,-390)
			AIRFALL = true
			FALL = false
			YACCEL = Vector2(0,30)
			
			hit_box.shape.extents = Vector2(32,12)
			hit_box.position = Vector2(FACING*51,-82)
			shapecast.shape.extents = Vector2(32,12)
			shapecast.position = Vector2(FACING*51,-82)
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func stand_heavy_punch_close() -> void:
	if STATENO != "Stand_Heavy_Punch_Close":
		PREVSTATENO = STATENO
		STATENO = "Stand_Heavy_Punch_Close"
		STATETYPE = "S"
		MOVETYPE = "A"
		PHYSICS = "S"
		CTRL = false
		velocity = Vector2(0,0)
	if ANIM != "Stand_Heavy_Punch_Close":
		anim_player.play("Stand_Heavy_Punch_Close")
		ANIMCOUNT = 1
	if ANIM == "Stand_Heavy_Punch_Close":
		if ANIMCOUNT == 1 and randi_range(0,1) == 0:
			voice_player.play_voice("res://Assets/Chars/K'/Sounds/K'_10-1.wav")
		if ANIMCOUNT == 3:
			sfx_player.play_sfx("HP_Whiff")
		if ANIMCOUNT == 11:
			MOVECONTACT = 0
		if ANIMCOUNT >= 5 and ANIMCOUNT < 8:
			PRIORITY = 3
			ATTR = [STATETYPE,"N","",""]
			ANIMTYPE = "Hard"
			DAMAGE = [35, 0]
			GETPOWER = [35,35]
			GIVEPOWER = [8,8]
			HITFLAG = "MAF"
			GUARDFLAG = "MA"
			PAUSETIME = [7,7]
			HITSPARK = "Hit_Hard"
			HITSOUND = "HP_Hit"
			GUARDSPARK = "Guard_Hard"
			GUARDSOUND = "Guard_Hard"
			SPARKXY = Vector2(-10,-85)
			HITTIME = 17
			GROUNDTYPE = "High"
			GROUNDVELOCITY = Vector2(-360,0)
			AIRTYPE = "High"
			AIRVELOCITY = Vector2(-270,-390)
			AIRFALL = true
			FALL = false
			YACCEL = Vector2(0,30)
			
			hit_box.shape.extents = Vector2(18,20)
			hit_box.position = Vector2(FACING*30,-64)
			shapecast.shape.extents = Vector2(18,20)
			shapecast.position = Vector2(FACING*30,-64)
		if ANIMCOUNT >= 11 and ANIMCOUNT < 14:
			PRIORITY = 3
			ATTR = [STATETYPE,"N","",""]
			ANIMTYPE = "Hard"
			DAMAGE = [53, 0]
			GETPOWER = [25,25]
			GIVEPOWER = [8,8]
			HITFLAG = "MAF"
			GUARDFLAG = "MA"
			PAUSETIME = [11,11]
			HITSPARK = "Hit_Hard"
			HITSOUND = "HP_Hit"
			GUARDSPARK = "Guard_Hard"
			GUARDSOUND = "Guard_Hard"
			SPARKXY = Vector2(-10,-85)
			HITTIME = 17
			GROUNDTYPE = "High"
			GROUNDVELOCITY = Vector2(-360,0)
			AIRTYPE = "High"
			AIRVELOCITY = Vector2(-270,-390)
			AIRFALL = true
			FALL = false
			YACCEL = Vector2(0,30)
			
			hit_box.shape.extents = Vector2(23,21)
			hit_box.position = Vector2(FACING*34,-85)
			shapecast.shape.extents = Vector2(23,21)
			shapecast.position = Vector2(FACING*34,-85)
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func stand_heavy_kick_far() -> void:
	if STATENO != "Stand_Heavy_Kick_Far":
		PREVSTATENO = STATENO
		STATENO = "Stand_Heavy_Kick_Far"
		STATETYPE = "S"
		MOVETYPE = "A"
		PHYSICS = "S"
		CTRL = false
		velocity = Vector2(0,0)
	if ANIM != "Stand_Heavy_Kick_Far":
		anim_player.play("Stand_Heavy_Kick_Far")
		ANIMCOUNT = 1
	if ANIM == "Stand_Heavy_Kick_Far":
		if ANIMCOUNT == 1 and randi_range(0,1) == 0:
			voice_player.play_voice("res://Assets/Chars/K'/Sounds/K'_10-1.wav")
		if ANIMCOUNT == 13:
			sfx_player.play_sfx("HK_Whiff")
		if ANIMCOUNT >= 16 and ANIMCOUNT < 22:
			PRIORITY = 3
			ATTR = [STATETYPE,"N","",""]
			ANIMTYPE = "Hard"
			DAMAGE = [88, 0]
			GETPOWER = [53,53]
			GIVEPOWER = [8,8]
			HITFLAG = "MAF"
			GUARDFLAG = "MA"
			PAUSETIME = [11,11]
			HITSPARK = "Hit_Hard"
			HITSOUND = "HK_Hit"
			GUARDSPARK = "Guard_Hard"
			GUARDSOUND = "Guard_Hard"
			SPARKXY = Vector2(-10,-85)
			HITTIME = 17
			GROUNDTYPE = "High"
			GROUNDVELOCITY = Vector2(-360,0)
			AIRTYPE = "High"
			AIRVELOCITY = Vector2(-270,-390)
			AIRFALL = true
			FALL = false
			YACCEL = Vector2(0,30)
			
			hit_box.shape.extents = Vector2(30,18)
			hit_box.position = Vector2(FACING*63,-76)
			shapecast.shape.extents = Vector2(30,18)
			shapecast.position = Vector2(FACING*63,-76)
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func stand_heavy_kick_close() -> void:
	if STATENO != "Stand_Heavy_Kick_Close":
		PREVSTATENO = STATENO
		STATENO = "Stand_Heavy_Kick_Close"
		STATETYPE = "S"
		MOVETYPE = "A"
		PHYSICS = "S"
		CTRL = false
		velocity = Vector2(0,0)
	if ANIM != "Stand_Heavy_Kick_Close":
		anim_player.play("Stand_Heavy_Kick_Close")
		ANIMCOUNT = 1
	if ANIM == "Stand_Heavy_Kick_Close":
		if ANIMCOUNT == 1 and randi_range(0,1) == 0:
			voice_player.play_voice("res://Assets/Chars/K'/Sounds/K'_10-1.wav")
		if ANIMCOUNT == 5:
			sfx_player.play_sfx("HK_Whiff")
		if ANIMCOUNT >= 8 and ANIMCOUNT < 11:
			PRIORITY = 3
			ATTR = [STATETYPE,"N","",""]
			ANIMTYPE = "Hard"
			DAMAGE = [67, 0]
			GETPOWER = [53,53]
			GIVEPOWER = [8,8]
			HITFLAG = "MAF"
			GUARDFLAG = "MA"
			PAUSETIME = [11,11]
			HITSPARK = "Hit_Hard"
			HITSOUND = "HK_Hit"
			GUARDSPARK = "Guard_Hard"
			GUARDSOUND = "Guard_Hard"
			SPARKXY = Vector2(-10,-50)
			HITTIME = 17
			GROUNDTYPE = "Low"
			GROUNDVELOCITY = Vector2(-360,0)
			AIRTYPE = "High"
			AIRVELOCITY = Vector2(-270,-390)
			AIRFALL = true
			FALL = false
			YACCEL = Vector2(0,30)
			
			hit_box.shape.extents = Vector2(20,17)
			hit_box.position = Vector2(FACING*28,-40)
			shapecast.shape.extents = Vector2(20,17)
			shapecast.position = Vector2(FACING*28,-40)
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func light_eine_trigger() -> void:
	if STATENO != "Light_Eine_Trigger":
		PREVSTATENO = STATENO
		STATENO = "Light_Eine_Trigger"
		STATETYPE = "S"
		MOVETYPE = "A"
		PHYSICS = "S"
		CTRL = false
		velocity = Vector2(0,0)
		if TEAMSIDE == 1:
			System.P1PowerCurrent += 35
		else:
			System.P2PowerCurrent += 35
	if ANIM != "Light_Eine_Trigger":
		anim_player.play("Light_Eine_Trigger")
		ANIMCOUNT = 1
	if ANIM == "Light_Eine_Trigger":
		if ANIMCOUNT == 1:
			voice_player.play_voice("res://Assets/Chars/K'/Sounds/K'_10-10.wav")
		if ANIMCOUNT == 4:
			var explod = preload("res://Assets/Effects/K'_Explod.tscn")
			var instance = explod.instantiate()
			add_child(instance)
			instance.POS = global_position + Vector2(0*FACING,0)
			instance.FACING = FACING
			instance.BINDTIME = 0
			instance.SPRPRIORITY = 5
			instance.play_anim("Eine_Trigger")
	if ANIMCOUNT >= 16 and ANIMCOUNT < 23:
		if "F" in INPUT[INPUT.size()-1][0].rsplit() and "a" in INPUT[INPUT.size()-1][0].rsplit(" "):
			second_shoot()
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func heavy_eine_trigger() -> void:
	if STATENO != "Heavy_Eine_Trigger":
		PREVSTATENO = STATENO
		STATENO = "Heavy_Eine_Trigger"
		STATETYPE = "S"
		MOVETYPE = "A"
		PHYSICS = "S"
		CTRL = false
		velocity = Vector2(0,0)
		if TEAMSIDE == 1:
			System.P1PowerCurrent += 35
		else:
			System.P2PowerCurrent += 35
	if ANIM != "Heavy_Eine_Trigger":
		anim_player.play("Heavy_Eine_Trigger")
		ANIMCOUNT = 1
	if ANIM == "Heavy_Eine_Trigger":
		if ANIMCOUNT == 1:
			voice_player.play_voice("res://Assets/Chars/K'/Sounds/K'_10-10.wav")
		if ANIMCOUNT == 6:
			var explod = preload("res://Assets/Effects/K'_Explod.tscn")
			var instance = explod.instantiate()
			add_child(instance)
			instance.POS = global_position + Vector2(0*FACING,0)
			instance.FACING = FACING
			instance.SPRPRIORITY = 5
			instance.play_anim("Eine_Trigger")
	if ANIMCOUNT >= 17 and ANIMCOUNT < 23:
		if "F" in INPUT[INPUT.size()-1][0].rsplit() and "a" in INPUT[INPUT.size()-1][0].rsplit(" "):
			second_shoot()
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func second_shoot() -> void:
	if STATENO != "Second_Shoot":
		PREVSTATENO = STATENO
		STATENO = "Second_Shoot"
		STATETYPE = "S"
		MOVETYPE = "A"
		PHYSICS = "S"
		CTRL = false
		velocity = Vector2(0,0)
		if TEAMSIDE == 1:
			System.P1PowerCurrent += 35
		else:
			System.P2PowerCurrent += 35
	if ANIM != "Second_Shoot":
		anim_player.play("Second_Shoot")
		ANIMCOUNT = 1
	if ANIM == "Second_Shoot":
		if ANIMCOUNT == 1:
			voice_player.play_voice("res://Assets/Chars/K'/Sounds/K'_10-11.wav")
		if ANIMCOUNT == 2 or ANIMCOUNT == 4:
			global_position.x += 8
		if ANIMCOUNT == 8:
			sfx_player.play_sfx("Second_Shoot")
			var explod = preload("res://Assets/Effects/K'_Explod.tscn")
			var instance = explod.instantiate()
			add_child(instance)
			instance.POS = global_position + Vector2(48*FACING,-28)
			if PREVSTATENO == "Light_Eine_Trigger":
				instance.VEL = Vector2(4,0)
			else:
				instance.VEL = Vector2(7,0)
			instance.FACING = FACING
			instance.SPRPRIORITY = 5
			instance.play_anim("Second_Shoot")
	if ANIMTIME == 0:
		CTRL = true
		stand()
	hurt_box.shape.extents = Vector2(17, 53)
	hurt_box.position = Vector2(0, -53)

func get_hit_ground() -> void:
	print(GHVANIMTYPE)
	print(GHVDAMAGE)
	print(GHVPAUSETIME)
	print(GHVHITTIME)
	print(GHVTYPE)
	print(GHVVELOCITY)
	print(GHVFALL)
	print(GHVYACCEL)

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
	if PHYSICS == "A":
		velocity += GRAVITY# get_gravity() * delta
		
	if PHYSICS == "S":
		if (ANIM == "Stand" or ANIM == "Turning") and velocity.x*delta <= 2:
			velocity.x = 0
		velocity.x *= STAND_FRICTION
	if PHYSICS == "C":
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
		
func _hit_box_check() -> void:
	var target = null
	if shapecast.is_colliding():
		target = shapecast.get_collider(0).get_parent()
		
	if target != null and target != self and MOVETYPE == "A" and MOVECONTACT == 0:
		var scene = preload("res://Assets/Effects/Spark.tscn")
		var check = target._get_hit_check(HITFLAG, GUARDFLAG, PRIORITY, ATTR, ANIMTYPE, DAMAGE, GIVEPOWER, PAUSETIME, HITTIME, GROUNDTYPE, GROUNDVELOCITY, AIRTYPE, AIRVELOCITY, AIRFALL, FALL, YACCEL, PALFXTIME, PALFXADD, PALFXMUL, PALFXSINADD, PALFXCOLOR, PALFXINVERTALL)
		if check == "Hit":
			z_index = 1
			var instance = scene.instantiate()
			add_child(instance)
			instance._play_spark(HITSPARK)
			instance.global_position = target.global_position-Vector2(15,0)+Vector2(-SPARKXY.x,SPARKXY.y)
			instance.POS = target.global_position-Vector2(15,0)+Vector2(-SPARKXY.x,SPARKXY.y)
			MOVECONTACT = 1
			HITCOUNT += 1
			ANIMCOUNTREMAIN = ANIMCOUNT-1
			HITSHAKETIME = PAUSETIME[0]
			sfx_player.play_sfx(HITSOUND)
			if TEAMSIDE == 1:
				System.P1PowerCurrent += GETPOWER[0]
			else:
				System.P2PowerCurrent += GETPOWER[0]
		elif check == "Guard":
			var instance = scene.instantiate()
			add_child(instance)
			instance._play_spark(GUARDSPARK)
			instance.global_position = target.global_position-Vector2(15,0)+Vector2(-SPARKXY.x,SPARKXY.y)
			instance.POS = target.global_position-Vector2(15,0)+Vector2(-SPARKXY.x,SPARKXY.y)
			MOVECONTACT = 1
			HITCOUNT += 1
			ANIMCOUNTREMAIN = ANIMCOUNT-1
			HITSHAKETIME = GUARDPAUSETIME[0]
			if TEAMSIDE == 1:
				System.P1PowerCurrent += GETPOWER[0]
			else:
				System.P2PowerCurrent += GETPOWER[0]
		
func _on_hit_box_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	if target != self and false:
		var System = get_node("/root/MainGame/System")
		var scene = preload("res://Assets/Effects/Spark.tscn")
		var check = target._get_hit_check(HITFLAG, GUARDFLAG, PRIORITY, ATTR, ANIMTYPE, DAMAGE, PAUSETIME, HITTIME, GROUNDTYPE, GROUNDVELOCITY, AIRTYPE, AIRVELOCITY, AIRFALL, FALL, YACCEL)
		if check == "Hit":
			var instance = scene.instantiate()
			add_child(instance)
			instance._play_spark(HITSPARK)
			if TEAMSIDE == 1:
				System.P1PowerCurrent += GETPOWER[0]
			else:
				System.P2PowerCurrent += GETPOWER[0]
			HITSHAKETIME = PAUSETIME[0]
		elif check == "Guard":
			var instance = scene.instantiate()
			add_child(instance)
			instance._play_spark(GUARDSPARK)
			if TEAMSIDE == 1:
				System.P1PowerCurrent += GETPOWER[0]
			else:
				System.P2PowerCurrent += GETPOWER[0]
			HITSHAKETIME = GUARDPAUSETIME[0]

func _get_hit_check(CHITFLAG, CGUARDFLAG, CPRIORITY: int, CGHVATTR: Array, CGHVANIMTYPE, CGHVDAMAGE, CGHVPAUSETIME, CGHVHITTIME, CGHVGTYPE, CGHVGVELOCITY, CGHVATYPE, CGHVAVELOCITY, CGHVAFALL, CGHVFALL, CGHVYACCEL) -> String:
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
			GHVANIMTYPE = CGHVANIMTYPE
			GHVDAMAGE = CGHVDAMAGE
			GHVPAUSETIME = CGHVPAUSETIME[1]
			GHVHITTIME = CGHVHITTIME
			GHVTYPE = CGHVGTYPE
			GHVVELOCITY = CGHVGVELOCITY
			GHVFALL = CGHVFALL
			GHVYACCEL = CGHVYACCEL
			get_hit_ground()
			return "Hit"
		elif STATETYPE == "A" or (STATETYPE == "S" or STATETYPE == "C") and CGHVFALL:
			GHVANIMTYPE = CGHVANIMTYPE
			GHVDAMAGE = CGHVDAMAGE
			GHVPAUSETIME = CGHVPAUSETIME[1]
			GHVHITTIME = CGHVHITTIME
			GHVTYPE = CGHVATYPE
			GHVVELOCITY = CGHVAVELOCITY
			if CGHVFALL:
				GHVFALL = CGHVFALL
			else:
				GHVFALL = CGHVAFALL
			GHVYACCEL = CGHVYACCEL
			get_hit_air()
			return "Hit"
			
	return "None"
