extends Node3D

const CAR_SCRIPT = preload("res://scripts/car_controller.gd")
const CAMERA_SCRIPT = preload("res://scripts/follow_camera.gd")

var world_root: Node3D
var car: DriftCar
var chase_camera: DriftFollowCamera
var hud: CanvasLayer
var score_label: Label
var combo_label: Label
var speed_label: Label
var angle_label: Label
var map_label: Label
var current_map: int = 0
var map_names := ["PARKING LOT", "CITY BLOCK", "TOUGE ROAD"]

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _configure_input()
    world_root = Node3D.new()
    world_root.name = "World"
    add_child(world_root)
    _build_world()
    _spawn_car()
    _build_hud()

func _configure_input() -> void:
    var bindings := {
        "accelerate": [KEY_UP, KEY_W],
        "brake": [KEY_DOWN, KEY_S],
        "steer_left": [KEY_LEFT, KEY_A],
        "steer_right": [KEY_RIGHT, KEY_D],
        "handbrake": [KEY_SHIFT, KEY_SPACE],
        "reset_car": [KEY_R]
    }
    for action in bindings:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        for code in bindings[action]:
            var event := InputEventKey.new()
            event.physical_keycode = code
            InputMap.action_add_event(action, event)

func _make_material(color: Color, roughness: float = 0.8, metallic: float = 0.0) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material

func _add_box(parent: Node3D, position: Vector3, size: Vector3, color: Color, solid: bool = true) -> Node3D:
    var node: Node3D
    if solid:
        var body := StaticBody3D.new()
        var collision := CollisionShape3D.new()
        var collision_shape := BoxShape3D.new()
        collision_shape.size = size
        collision.shape = collision_shape
        body.add_child(collision)
        node = body
    else:
        node = Node3D.new()

    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    mesh_instance.material_override = _make_material(color)
    node.add_child(mesh_instance)
    node.position = position
    parent.add_child(node)
    return node

func _build_world() -> void:
    var environment_node := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_SKY
    environment.sky = Sky.new()
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.42, 0.48, 0.58)
    environment.ambient_light_energy = 0.6
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment_node.environment = environment
    world_root.add_child(environment_node)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48.0, -32.0, 0.0)
    sun.light_energy = 1.1
    sun.shadow_enabled = true
    world_root.add_child(sun)

    var ground_body := StaticBody3D.new()
    ground_body.name = "Ground"
    var ground_collision := CollisionShape3D.new()
    var ground_shape := BoxShape3D.new()
    ground_shape.size = Vector3(220.0, 0.5, 220.0)
    ground_collision.shape = ground_shape
    ground_collision.position.y = -0.25
    ground_body.add_child(ground_collision)
    var ground_mesh := MeshInstance3D.new()
    var ground_plane := PlaneMesh.new()
    ground_plane.size = Vector2(220.0, 220.0)
    ground_mesh.mesh = ground_plane
    ground_mesh.material_override = _make_material(Color(0.105, 0.115, 0.125), 0.95)
    ground_body.add_child(ground_mesh)
    world_root.add_child(ground_body)

    match current_map:
        0:
            _build_parking()
        1:
            _build_city()
        2:
            _build_touge()

func _build_parking() -> void:
    for i in range(-7, 8):
        _add_box(world_root, Vector3(float(i) * 4.0, 0.015, -6.0), Vector3(0.07, 0.025, 18.0), Color(0.82, 0.82, 0.76), false)
    for x in [-27.0, 27.0]:
        _add_box(world_root, Vector3(x, 1.2, 0.0), Vector3(0.8, 2.4, 90.0), Color(0.18, 0.20, 0.22))
    for z in [-25.0, 25.0]:
        _add_box(world_root, Vector3(0.0, 1.2, z), Vector3(54.0, 2.4, 0.8), Color(0.18, 0.20, 0.22))
    for i in range(8):
        _add_box(world_root, Vector3(-18.0 + float(i) * 5.0, 0.55, 17.0), Vector3(2.0, 1.1, 2.0), Color(0.24, 0.26, 0.28))

func _build_city() -> void:
    for x in range(-3, 4):
        for z in range(-3, 4):
            if abs(x) <= 1 and abs(z) <= 1:
                continue
            var height := 9.0 + float(abs(x * 7 + z * 3) % 5) * 3.0
            var tint := Color(0.105 + 0.012 * float(abs(x)), 0.13, 0.18 + 0.012 * float(abs(z)))
            _add_box(world_root, Vector3(float(x) * 23.0, height * 0.5, float(z) * 23.0), Vector3(14.0, height, 14.0), tint)
    for i in range(-5, 6):
        _add_box(world_root, Vector3(float(i) * 4.0, 0.02, 0.0), Vector3(0.12, 0.025, 36.0), Color(0.9, 0.75, 0.2), false)

func _build_touge() -> void:
    for i in range(18):
        var t := float(i)
        var angle := t * 0.34
        var point := Vector3(sin(angle) * 18.0, 0.0, -t * 8.0)
        var road := _add_box(world_root, point, Vector3(15.0, 0.18, 11.0), Color(0.19, 0.20, 0.21), false)
        road.rotation.y = -angle * 0.7
        var barrier_position := point + Vector3(cos(angle) * 9.0, 0.65, sin(angle) * 9.0)
        var barrier := _add_box(world_root, barrier_position, Vector3(0.45, 1.3, 10.0), Color(0.62, 0.65, 0.66))
        barrier.rotation.y = -angle * 0.7

func _build_car_visuals(target: DriftCar) -> void:
    var body_mesh := MeshInstance3D.new()
    var body := BoxMesh.new()
    body.size = Vector3(1.9, 0.58, 4.0)
    body_mesh.mesh = body
    body_mesh.position.y = 0.72
    body_mesh.material_override = _make_material(Color(0.08, 0.22, 0.32), 0.24, 0.72)
    target.add_child(body_mesh)

    var cabin_mesh := MeshInstance3D.new()
    var cabin := BoxMesh.new()
    cabin.size = Vector3(1.55, 0.62, 1.85)
    cabin_mesh.mesh = cabin
    cabin_mesh.position = Vector3(0.0, 1.28, -0.28)
    cabin_mesh.material_override = _make_material(Color(0.025, 0.055, 0.075), 0.14, 0.35)
    target.add_child(cabin_mesh)

    for x in [-1.0, 1.0]:
        for z in [-1.25, 1.25]:
            var wheel := MeshInstance3D.new()
            var cylinder := CylinderMesh.new()
            cylinder.top_radius = 0.37
            cylinder.bottom_radius = 0.37
            cylinder.height = 0.25
            wheel.mesh = cylinder
            wheel.rotation.z = PI * 0.5
            wheel.position = Vector3(x, 0.42, z)
            wheel.material_override = _make_material(Color(0.025, 0.025, 0.03), 0.95)
            target.add_child(wheel)

func _spawn_car() -> void:
    car = CAR_SCRIPT.new() as DriftCar
    car.name = "PlayerCar"
    car.position = Vector3(0.0, 0.15, 0.0)

    var collision := CollisionShape3D.new()
    var collision_box := BoxShape3D.new()
    collision_box.size = Vector3(1.8, 1.1, 3.8)
    collision.shape = collision_box
    collision.position.y = 0.7
    car.add_child(collision)
    _build_car_visuals(car)
    add_child(car)

    if chase_camera != null:
        chase_camera.queue_free()
    chase_camera = CAMERA_SCRIPT.new() as DriftFollowCamera
    chase_camera.name = "ChaseCamera"
    chase_camera.target = car
    chase_camera.current = true
    chase_camera.fov = 75.0
    chase_camera.global_position = car.global_position + Vector3(0.0, 4.0, 8.5)
    add_child(chase_camera)
    chase_camera.look_at(car.global_position + Vector3.UP * 0.9, Vector3.UP)

func _build_hud() -> void:
    hud = CanvasLayer.new()
    add_child(hud)

    var panel := PanelContainer.new()
    panel.position = Vector2(22.0, 20.0)
    panel.custom_minimum_size = Vector2(310.0, 142.0)
    hud.add_child(panel)

    var stack := VBoxContainer.new()
    panel.add_child(stack)

    var title := Label.new()
    title.text = "SLIDE CULT  /  DRIFT SESSION"
    title.add_theme_font_size_override("font_size", 16)
    stack.add_child(title)

    score_label = Label.new()
    score_label.add_theme_font_size_override("font_size", 28)
    stack.add_child(score_label)

    combo_label = Label.new()
    stack.add_child(combo_label)

    speed_label = Label.new()
    stack.add_child(speed_label)

    angle_label = Label.new()
    stack.add_child(angle_label)

    map_label = Label.new()
    map_label.position = Vector2(22.0, 174.0)
    hud.add_child(map_label)

    var controls := Label.new()
    controls.text = "ARROWS / WASD: DRIVE    SHIFT: HANDBRAKE    R: RESET    1-3: MAP"
    controls.position = Vector2(22.0, 680.0)
    hud.add_child(controls)
    _refresh_map_label()

func _refresh_map_label() -> void:
    if map_label != null:
        map_label.text = "MAP: %s    [1] PARKING  [2] CITY  [3] TOUGE" % map_names[current_map]

func _process(_delta: float) -> void:
    if car == null:
        return
    score_label.text = "%08d" % car.total_score
    combo_label.text = "COMBO  x%.1f    |    CHAIN %d" % [car.combo, car.session_score]
    speed_label.text = "SPEED  %03d KM/H" % int(absf(car.forward_speed) * 3.6)
    angle_label.text = "DRIFT ANGLE  %.0f°" % absf(car.drift_angle)

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey:
        return
    var key_event := event as InputEventKey
    if not key_event.pressed or key_event.echo:
        return

    match key_event.physical_keycode:
        KEY_ESCAPE:
            get_tree().paused = not get_tree().paused
            get_viewport().set_input_as_handled()
        KEY_1:
            if current_map != 0:
                _switch_map(0)
            get_viewport().set_input_as_handled()
        KEY_2:
            if current_map != 1:
                _switch_map(1)
            get_viewport().set_input_as_handled()
        KEY_3:
            if current_map != 2:
                _switch_map(2)
            get_viewport().set_input_as_handled()

func _switch_map(index: int) -> void:
    current_map = index
    if car != null:
        car.queue_free()
        car = null
    if chase_camera != null:
        chase_camera.queue_free()
        chase_camera = null
    for child in world_root.get_children():
        child.queue_free()
    await get_tree().process_frame
    _build_world()
    _spawn_car()
    _refresh_map_label()
