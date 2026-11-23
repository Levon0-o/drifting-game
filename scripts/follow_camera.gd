extends SpringArm3D
class_name DriftFollowCamera

@export var target: Node3D
@export var follow_smoothing: float = 5.0
@export var look_height: float = 0.8

func _process(delta: float) -> void:
    if target == null:
        return
    global_position = global_position.lerp(target.global_position, 1.0 - exp(-follow_smoothing * delta))
    var look_target := target.global_position + Vector3.UP * look_height
    if get_child_count() > 0 and get_child(0) is Camera3D:
        var camera := get_child(0) as Camera3D
        camera.look_at(look_target, Vector3.UP)
