extends CharacterBody2D


@export var jump_power : int = -400
@export var speed : int = 300
@export var end_jump_early_timeout : float = 300
@export var jump_buffer_timeout : float = 150
@export var grounding_force : float = 1.5
@export var fall_acceleration : float = 1000.0
@export var max_fall_speed : float = 800
@export var Jump_ended_early_gravity_modifier : float = 3.0
@export var gravity : float = 9.8

const SPEED = 300.0

var _endedJumpEarly : bool = false
var _grounded : bool = false
var JumpHeld : bool = false
var JumpDown : bool = false
var _jumpToConsume : bool = false
var CanUseCoyote : bool = false
var _bufferedJumpUsable : bool = false
var _coyoteUsable : bool = false


var _frameVelocity : Vector2 = Vector2.ZERO
var _timeJumpWasPressed : int = 0

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

	ApplyVelocity()
	move_and_slide()




func HandleJump() -> void:
	if !_endedJumpEarly && !_grounded && !JumpHeld && velocity.y > 0 && Time.get_ticks_msec() < (_timeJumpWasPressed + end_jump_early_timeout) :
		_endedJumpEarly = true
		#  print("ended early")
		
	if _jumpToConsume && HasBufferedJump():
		# print("abt to jump")
		if _grounded || CanUseCoyote:
			ExecuteJump()
			_jumpToConsume = false;

func ExecuteJump():
	_endedJumpEarly = false
	_timeJumpWasPressed = 0
	_bufferedJumpUsable = false
	_coyoteUsable = false
	_frameVelocity.y = jump_power

func HandleGravity(delta: float):
	if _grounded && _frameVelocity.y <= 0:
		_frameVelocity.y = grounding_force
	else:
		var inAirGravity = fall_acceleration
		if _endedJumpEarly && _frameVelocity.y > 0 :
			inAirGravity *= Jump_ended_early_gravity_modifier
		_frameVelocity.y = move_toward(_frameVelocity.y, max_fall_speed, inAirGravity * delta)
			


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Jump"):
		JumpHeld = true
		if JumpDown  == false:
			JumpDown = true

	else:
		JumpDown = false
		JumpHeld = false
		
		
	if JumpDown:
		_jumpToConsume = true
		JumpDown = false
		_timeJumpWasPressed = Time.get_ticks_msec()
		
func CheckGround():
	var previously_grounded = _grounded
	_grounded = is_on_floor()
	_bufferedJumpUsable = true
	
	if !previously_grounded && _grounded:
		_coyoteUsable = true
		_endedJumpEarly = false
		

func ApplyVelocity():
	velocity = _frameVelocity

func HasBufferedJump() -> bool:
	var buffered : bool = false
	# print(_bufferedJumpUsable)
	if _bufferedJumpUsable && Time.get_ticks_msec() < _timeJumpWasPressed + jump_buffer_timeout:
		buffered = true
	else:
		_bufferedJumpUsable = false
		
	return buffered
