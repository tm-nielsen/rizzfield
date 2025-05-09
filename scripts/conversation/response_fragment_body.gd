class_name ResponseFragmentBody
extends RigidBody3D

signal grabbed
signal dropped
signal placed
signal freed

enum State {FREE, HELD, PLACED}
const FREE = State.FREE
const HELD = State.HELD
const PLACED = State.PLACED

const GRAB_ACTION = "attack"
const FLIP_GRAB_ACTION = "block"

@export var fragment: ResponseFragment
@export var held_depth_offset = 0.5

@export_subgroup("colours", "colour")
@export var colour_hovered := Color.WHITE
@export var colour_grabbed := Color.DIM_GRAY
@export var colour_placed := Color.WEB_GREEN
@export var colour_placed_and_hovered := Color.LIME_GREEN

var camera_depth: float = 2
var grab_action: String = GRAB_ACTION
var placement_rotation: Vector3
var is_horizontal: bool: get = _get_is_horizontal

var state: State
var contains_mouse: bool

var mesh_instance: MeshInstance3D
var material: ShaderMaterial
var collision_shape = CollisionShape3D


func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

    mesh_instance = fragment.create_mesh_instance()
    material = fragment.base_material.duplicate()
    mesh_instance.material_override = material
    set_colour(fragment.colour)
    add_child(mesh_instance)

    collision_shape = fragment.create_collision_shape()
    add_child(collision_shape)

    var visibility_notifier := VisibleOnScreenNotifier3D.new()
    visibility_notifier.aabb = mesh_instance.get_aabb()
    visibility_notifier.screen_exited.connect(queue_free)
    add_child(visibility_notifier)

func _exit_tree() -> void:
    freed.emit()


func _physics_process(_delta) -> void:
    if state == HELD:
        global_position = get_mouse_world_position(camera_depth)
        global_position.y += held_depth_offset

func _process(_delta) -> void:
    if state == HELD:
        if Input.is_action_just_released(grab_action):
            drop()
    elif contains_mouse:
        var grab_pressed = Input.is_action_just_pressed(GRAB_ACTION)
        var flip_grab_pressed = Input.is_action_just_pressed(FLIP_GRAB_ACTION)
        if grab_pressed || flip_grab_pressed:
            placement_rotation = get_placement_rotation(flip_grab_pressed)
            grab_action = FLIP_GRAB_ACTION if flip_grab_pressed else GRAB_ACTION
            grab()

func grab():
    state = HELD
    freeze = true
    set_colour(colour_grabbed)
    grabbed.emit()

func drop():
    state = FREE
    freeze = false
    if contains_mouse: set_colour(colour_hovered)
    else: set_colour(fragment.colour)
    dropped.emit()


func place_and_freeze(point: Vector3):
    state = PLACED
    place(point)
    freeze = true
    if contains_mouse: set_colour(colour_placed_and_hovered)
    else: set_colour(colour_placed)
    placed.emit()

func place(point: Vector3):
    global_position = point
    rotation = placement_rotation


func rotate_placement(angle: float):
    placement_rotation.y = ElasticValue.wrap_value(
        placement_rotation.y + angle, PI
    )


func scale_children(value: float) -> void:
    var child_scale = Vector3.ONE * value
    for child in get_children():
        if child is Node3D:
            child.scale = child_scale


func set_colour(colour: Color) -> void:
    material.set_shader_parameter("albedo_colour", colour)


func get_mouse_world_position(z_depth: float = 1) -> Vector3:
    var viewport = get_viewport()
    var mouse_position = viewport.get_mouse_position()
    var camera = viewport.get_camera_3d()
    return camera.project_position(mouse_position, z_depth)


func get_placement_rotation(flipped: bool) -> Vector3:
    if !flipped: return placement_rotation
    if is_horizontal:
        placement_rotation.z = ElasticValue.wrap_value(
            placement_rotation.z + PI, PI
        )
    else:
        placement_rotation.x = ElasticValue.wrap_value(
            placement_rotation.x + PI, PI
        )
    return placement_rotation

func _get_is_horizontal() -> bool:
    return (
        is_zero_approx(placement_rotation.y) ||
        is_equal_approx(placement_rotation.y, PI)
    )


func _on_mouse_entered():
    contains_mouse = true
    match state:
        FREE: set_colour(colour_hovered)
        PLACED: set_colour(colour_placed_and_hovered)

func _on_mouse_exited():
    contains_mouse = false
    match state:
        FREE: set_colour(fragment.colour)
        PLACED: set_colour(colour_placed)
