extends CharacterBody2D

@onready var ground_cast := $groundcast
@onready var ceiling_cast := $ceilingcast

@export var jump_power : int = -600
@export var max_speed : int = 300
@export var end_jump_early_timeout : float = 300
@export var coyote_timeout : float = 150
@export var jump_buffer_timeout : float = 150
@export var grounding_force : float = 1.5
@export var fall_acceleration : float = 1800.0
@export var max_fall_speed : float = 800
@export var Jump_ended_early_gravity_modifier : float = 3.0
@export var gravity : float = 9.8
@export var acceleration : float = 10000



const SPEED = 300.0

var _ceiled : bool = false
var _endedJumpEarly : bool = false
var _grounded : bool = false
var _leftHeld : bool = false
var _rightHeld : bool = false
var _JumpHeld : bool = false
var _JumpHeldPrev : bool = false
var _jumpToConsume : bool = false
var _bufferedJumpUsable : bool = false
var _coyoteUsable : bool = false





var _move : Vector2 = Vector2.ZERO
var _frameVelocity : Vector2 = Vector2.ZERO
var _timeJumpWasPressed : int = 0
var _timeLeftGround : int = 0
var _timeJumpWasReleased : int = 0

func _physics_process(delta: float) -> void:
		
	CheckGround()
	HandleGravity(delta)
	HandleJump()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	CheckCeiling()
	ApplyMovement(delta)
	ApplyVelocity()
	move_and_slide()




func HandleJump() -> void:

	if !_endedJumpEarly && !_grounded && !_JumpHeld && velocity.y < 0:
		_endedJumpEarly = true
		
	if _jumpToConsume && HasBufferedJump():
		if _grounded || canCoyote():
			ExecuteJump()
			_jumpToConsume = false;

func ExecuteJump():
	_endedJumpEarly = false
	_timeJumpWasPressed = 0
	_bufferedJumpUsable = false
	_coyoteUsable = false
	_frameVelocity.y = jump_power

func HandleGravity(delta: float):
	if _grounded && _frameVelocity.y >= 0:
		_frameVelocity.y = grounding_force
	else:
		var inAirGravity = fall_acceleration
		if _endedJumpEarly && _frameVelocity.y < 0 :
			
			inAirGravity *= Jump_ended_early_gravity_modifier
		_frameVelocity.y = move_toward(_frameVelocity.y, max_fall_speed, inAirGravity * delta)
			



func CheckCeiling():
	var prev_ceiled = _ceiled
	_ceiled = ceiling_cast.is_colliding()
	if !prev_ceiled && _ceiled:
		_frameVelocity.y = 1

func CheckGround():
	var previously_grounded = _grounded
	_grounded = ground_cast.is_colliding()
	_bufferedJumpUsable = true
	_coyoteUsable = true
	
	if !previously_grounded && _grounded:
		_coyoteUsable = true
		_endedJumpEarly = false
	elif previously_grounded && !_grounded:
		_timeLeftGround = Time.get_ticks_msec()

func ApplyVelocity():
	velocity = _frameVelocity

func HasBufferedJump() -> bool:
	var buffered : bool = false
	if _bufferedJumpUsable && Time.get_ticks_msec() < _timeJumpWasPressed + jump_buffer_timeout:
		buffered = true
	else:
		_bufferedJumpUsable = false
		
	return buffered

func canCoyote() -> bool:
	var coyotable := false
	if _coyoteUsable && Time.get_ticks_msec() < _timeLeftGround + coyote_timeout: 
		coyotable = true
	return coyotable

func ApplyMovement(delta: float):
	
	_frameVelocity.x = move_toward(_frameVelocity.x, _move.x * max_speed, acceleration * delta)

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Jump"):
		_JumpHeld = true
	
	if event.is_action_released("Jump"):
		_JumpHeld = false
		_timeJumpWasReleased = Time.get_ticks_msec()
	
	if event.is_action_pressed("Left"):
		_leftHeld = true
	if event.is_action_released("Left"):
		_leftHeld = false
	
	if event.is_action_pressed("Right"):
		_rightHeld = true
	if event.is_action_released("Right"):
		_rightHeld = false
		
		
	if _leftHeld:
		_move.x = -1
	elif _rightHeld:
		_move.x = 1
	else:
		_move.x = 0	
		
	if !_JumpHeldPrev && _JumpHeld:
		_jumpToConsume = true
		_timeJumpWasPressed = Time.get_ticks_msec()
	
	_JumpHeldPrev = _JumpHeld
