extends CharacterBody3D
class_name DriftCar

@export var acceleration: float = 25.0
@export var max_forward_speed: float = 38.0
@export var max_reverse_speed: float = 10.0
@export var steering_rate: float = 2.15
@export var grip: float = 8.0
@export var handbrake_grip: float = 1.25
@export var rolling_drag: float = 1.25

var forward_speed: float = 0.0
var lateral_speed: float = 0.0
var drift_angle: float = 0.0
var session_score: int = 0
var combo: float = 1.0
var combo_hold: float = 0.0
var total_score: int = 0
var spawn_transform: Transform3D

func _ready() -> void:
    spawn_transform = global_transform

func _physics_process(delta: float) -> void:
    var throttle := Input.get_action_strength("accelerate") - Input.get_action_strength("brake")
    var steer := Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
    var handbrake := Input.is_action_pressed("handbrake")

    forward_speed += throttle * acceleration * delta
    forward_speed = clampf(forward_speed, -max_reverse_speed, max_forward_speed)

    var drag_factor := rolling_drag * (0.2 if absf(throttle) > 0.05 else 1.0)
    forward_speed = move_toward(forward_speed, 0.0, drag_factor * delta)

    var speed_ratio := clampf(absf(forward_speed) / 7.0, 0.0, 1.0)
    var direction_sign := -1.0 if forward_speed < -0.1 else 1.0
    rotation.y += steer * steering_rate * speed_ratio * direction_sign * delta

    var current_grip := handbrake_grip if handbrake else grip
    lateral_speed = move_toward(lateral_speed, 0.0, current_grip * maxf(absf(forward_speed), 2.0) * delta)
    if handbrake and absf(forward_speed) > 4.0:
        lateral_speed += -steer * absf(forward_speed) * 0.34 * delta * 8.0
    elif absf(forward_speed) > 5.0:
        lateral_speed += -steer * absf(forward_speed) * 0.055 * delta * 8.0

    var forward := -global_transform.basis.z
    var right := global_transform.basis.x
    var planar_velocity := forward * forward_speed + right * lateral_speed
    velocity.x = planar_velocity.x
    velocity.z = planar_velocity.z
    velocity.y = -0.5
    move_and_slide()

    var actual_planar := Vector3(velocity.x, 0.0, velocity.z)
    if actual_planar.length() > 1.5:
        var forward_dir := -global_transform.basis.z
        var velocity_dir := actual_planar.normalized()
        var unsigned_angle := rad_to_deg(acos(clampf(forward_dir.dot(velocity_dir), -1.0, 1.0)))
        drift_angle = unsigned_angle * signf(forward_dir.cross(velocity_dir).y)
    else:
        drift_angle = 0.0

    _update_drift_score(delta)

    if Input.is_action_just_pressed("reset_car"):
        reset_car()

func _update_drift_score(delta: float) -> void:
    var valid_drift := absf(drift_angle) >= 9.0 and absf(forward_speed) >= 7.0
    if valid_drift:
        var base_points := int(absf(drift_angle) * absf(forward_speed) * delta * 0.55)
        session_score += base_points
        total_score += int(float(base_points) * combo)
        combo = minf(combo + delta * 0.18, 5.0)
        combo_hold = 1.6
    else:
        combo_hold -= delta
        if combo_hold <= 0.0:
            combo = 1.0
            session_score = 0

func reset_car() -> void:
    global_transform = spawn_transform
    velocity = Vector3.ZERO
    forward_speed = 0.0
    lateral_speed = 0.0
    drift_angle = 0.0
    session_score = 0
    combo = 1.0
    combo_hold = 0.0
