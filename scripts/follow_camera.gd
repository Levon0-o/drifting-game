extends Camera3D
class_name DriftFollowCamera

@export var target: Node3D
@export var follow_smoothing: float = 5.0
@export var follow_distance: float = 8.5
@export var follow_height: float = 4.0
@export var look_height: float = 0.9

func _process(delta: float) -> void:
    if target == null:
        return
    var desired_position := target.global_position + target.global_transform.basis.z * follow_distance + Vector3.UP * follow_height
    global_position = global_position.lerp(desired_position, 1.0 - exp(-follow_smoothing * delta))
    look_at(target.global_position + Vector3.UP * look_height, Vector3.UP)
