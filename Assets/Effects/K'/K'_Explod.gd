extends Node2D

@onready var parent = get_parent()
@onready var stageCamera = get_node("/root/MainGame/Stage").get_child(0).get_node("StageCamera")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var shapecast: ShapeCast2D = $ShapeCast2D

var MOVETYPE = "I"

var TIME: int = 0
var POS: Vector2 = Vector2(0,0)
var VEL: Vector2 = Vector2(0,0)
var ACCEL: Vector2 = Vector2(0,0)
var SCALE: Vector2 = Vector2(1,1)
var FACING: int = 1
var BINDTIME: int = 0
var SPRPRIORITY: int = 0

var ANIM
var ANIMTIME
var ANIMCOUNT

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

func _process(delta: float) -> void:
	if MOVETYPE == "I" or MOVETYPE == "H":
		MOVECONTACT = 0
		HITCOUNT = 0
	if MOVECONTACT > 0:
		MOVECONTACT += 1
	
	if anim_player.is_playing():
		ANIMCOUNT = 1 + int(ceil(anim_player.current_animation_position / (1/60.0) * 10)/10)
		
	shapecast.shape.extents = Vector2(0,0)
	shapecast.position = Vector2(0,9999)
	
	_hit_box_check()
	
	TIME += 1
	
	if TIME <= BINDTIME or BINDTIME == -1:
		POS = global_position
	else:
		VEL += ACCEL * FACING
		POS += VEL * FACING
		global_position = POS
		
	#Adjust character's facing
	if FACING == 1:
		sprite.flip_h = false
		sprite.offset = Vector2 (-107,-196)
	else:
		sprite.flip_h = true
		sprite.offset = Vector2 (-129,-196)
	
	#If is playing any animations
	if anim_player.is_playing():
		#Record current animation and animation frames left
		ANIM = anim_player.current_animation
		ANIMTIME = int(ceil(anim_player.get_animation(ANIM).length / (1/60.0) * 10)/10 - ceil(anim_player.current_animation_position / (1/60.0) * 10)/10)
		ANIMCOUNT = 1 + int(ceil(anim_player.current_animation_position / (1/60.0) * 10)/10)
	else:
		ANIMTIME = 0
		ANIMCOUNT = -1
	
	z_index = SPRPRIORITY
		
	if ANIM == "Eine_Trigger":
		if parent.STATENO == "Second_Shoot" and parent.ANIMCOUNT == 8:
			queue_free()
		MOVETYPE = "A"
		if ANIMCOUNT == 2:
			parent.sfx_player.play_sfx("Eine_Trigger")
		if ANIMCOUNT >= 4 and ANIMCOUNT < 15:
			PRIORITY = 3
			ATTR = ["A","","","S"]
			ANIMTYPE = "Hard"
			DAMAGE = [66, 0]
			GETPOWER = [54,54]
			GIVEPOWER = [8,8]
			HITFLAG = "MA"
			GUARDFLAG = "MA"
			PAUSETIME = [0,3]
			HITSPARK = "Hit_Hard"
			HITSOUND = "Flames_Hit"
			GUARDSPARK = "Guard_Hard"
			GUARDSOUND = "Guard_Hard"
			SPARKXY = Vector2(-10,-60)
			HITTIME = 17
			GROUNDTYPE = "High"
			GROUNDVELOCITY = Vector2(-360,0)
			AIRTYPE = "High"
			AIRVELOCITY = Vector2(-270,-390)
			AIRFALL = true
			FALL = false
			YACCEL = Vector2(0,30)
			PALFXTIME = 30
			PALFXADD = Vector3(80,-40,-140)
			PALFXMUL = Vector3(255,255,255)
			PALFXSINADD = Vector4(100,100,100,15)
			PALFXCOLOR = 0
			PALFXINVERTALL = true
			
			shapecast.shape.extents = Vector2(31,19)
			shapecast.position = Vector2(FACING*60,-40)
		
	if ANIM == "Second_Shoot":
		MOVETYPE = "A"
		if global_position.x <= stageCamera.LEFT_CORNER - 60 or global_position.x >= stageCamera.RIGHT_CORNER + 60:
			queue_free()
		if ANIMTIME == 0:
			anim_player.play("Second_Shoot")
			anim_player.seek(0)
		if true:
			PRIORITY = 3
			ATTR = ["A","","","S"]
			ANIMTYPE = "Hard"
			DAMAGE = [66, 0]
			GETPOWER = [54,54]
			GIVEPOWER = [8,8]
			HITFLAG = "MA"
			GUARDFLAG = "MA"
			PAUSETIME = [0,11]
			HITSPARK = "Hit_Hard"
			HITSOUND = "Flames_Hit"
			GUARDSPARK = "Guard_Hard"
			GUARDSOUND = "Guard_Hard"
			SPARKXY = Vector2(-10,-60)
			HITTIME = 17
			GROUNDTYPE = "Low"
			GROUNDVELOCITY = Vector2(-360,0)
			AIRTYPE = "High"
			AIRVELOCITY = Vector2(-270,-390)
			AIRFALL = true
			FALL = false
			YACCEL = Vector2(0,30)
			PALFXTIME = 30
			PALFXADD = Vector3(80,-40,-140)
			PALFXMUL = Vector3(255,255,255)
			PALFXSINADD = Vector4(100,100,100,15)
			PALFXCOLOR = 0
			PALFXINVERTALL = true
			
			shapecast.shape.extents = Vector2(21,11)
			shapecast.position = Vector2(FACING*-5,-40)
	
func play_anim(explod: String) -> void:
	anim_player.play(explod)
	ANIM = explod
	ANIMCOUNT = 1
	
func _hit_box_check() -> void:
	var target = null
	if shapecast.is_colliding():
		target = shapecast.get_collider(0).get_parent()
		
	if target != null and target != self and target != parent and MOVETYPE == "A" and MOVECONTACT == 0:
		var System = get_node("/root/MainGame/System")
		var scene = preload("res://Assets/Effects/Spark.tscn")
		var check = target._get_hit_check(HITFLAG, GUARDFLAG, PRIORITY, ATTR, ANIMTYPE, DAMAGE, GIVEPOWER, PAUSETIME, HITTIME, GROUNDTYPE, GROUNDVELOCITY, AIRTYPE, AIRVELOCITY, AIRFALL, FALL, YACCEL, PALFXTIME, PALFXADD, PALFXMUL, PALFXSINADD, PALFXCOLOR, PALFXINVERTALL)
		if check == "Hit":
			z_index = 1
			var instance = scene.instantiate()
			parent.add_child(instance)
			instance._play_spark(HITSPARK)
			instance.global_position = target.global_position-Vector2(15,0)+Vector2(-SPARKXY.x,SPARKXY.y)
			instance.POS = target.global_position-Vector2(15,0)+Vector2(-SPARKXY.x,SPARKXY.y)
			MOVECONTACT = 1
			HITCOUNT += 1
			ANIMCOUNTREMAIN = ANIMCOUNT-1
			HITSHAKETIME = PAUSETIME[0]
			parent.sfx_player.play_sfx(HITSOUND)
			if parent.TEAMSIDE == 1:
				System.P1PowerCurrent += GETPOWER[0]
			else:
				System.P2PowerCurrent += GETPOWER[0]
			if ANIM == "Second_Shoot":
				queue_free()
		elif check == "Guard":
			var instance = scene.instantiate()
			parent.add_child(instance)
			instance._play_spark(GUARDSPARK)
			instance.POS = target.global_position-Vector2(15,0)+Vector2(-SPARKXY.x,SPARKXY.y)
			MOVECONTACT = 1
			HITCOUNT += 1
			ANIMCOUNTREMAIN = ANIMCOUNT-1
			HITSHAKETIME = GUARDPAUSETIME[0]
			if parent.TEAMSIDE == 1:
				System.P1PowerCurrent += GETPOWER[0]
			else:
				System.P2PowerCurrent += GETPOWER[0]
			if ANIM == "Second_Shoot":
				queue_free()
		
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "Second_Shoot":
		queue_free()
