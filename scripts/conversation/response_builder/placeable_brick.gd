class_name PlaceableBrick
extends RigidBody3D

@export var held_depth_offset: float = 0.5
@export var mesh: MeshInstance3D
@export var collider: CollisionShape3D
@export var placement_grid: PlacementGrid

@export_subgroup("colours", "colour")
@export var colour_normal := Color.GRAY
@export var colour_hovered := Color.WHITE
@export var colour_grabbed := Color.DIM_GRAY

@onready var reset_position := position
@onready var reset_rotation := rotation
@onready var target_rotation := rotation
var camera_depth: float = 2

var held: bool
var contains_mouse: bool
var can_place: bool: get = _get_can_place


func _ready() -> void:
    GameModeSignalBus.conversation_started.connect(reset)
    GameModeSignalBus.brick_thrown.connect(disable)
    ExplorationSignalBus.brick_collected.connect(enable)
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    camera_depth = (
        get_viewport().get_camera_3d().global_position.y
        - placement_grid.global_position.y
    )
    disable()

func _physics_process(_delta) -> void:
    if held:
        global_position = get_mouse_world_position(camera_depth)
        global_position.y += held_depth_offset

func _process(_delta) -> void:
    if held:
        if Input.is_action_just_pressed("right"):
            rotate_placement(-PI / 2)
        if Input.is_action_just_pressed("left"):
            rotate_placement(PI / 2)
        if Input.is_action_just_released(
            ResponseFragmentBody.GRAB_ACTION
        ):
            drop()
    elif contains_mouse && Input.is_action_just_pressed(
        ResponseFragmentBody.GRAB_ACTION
    ):
        grab()


func grab():
    held = true
    freeze = true
    set_colour(colour_grabbed)

func drop():
    held = false
    freeze = false
    if contains_mouse: set_colour(colour_hovered)
    else: set_colour(colour_normal)
    if can_place: GameModeSignalBus.notify_brick_thrown()


func rotate_placement(angle: float):
    target_rotation.y = ElasticValue.wrap_value(
        target_rotation.y + angle, PI
    )


func set_colour(colour: Color):
    mesh.material_override.set_shader_parameter(
        "albedo_colour", colour
    )


func reset():
    position = reset_position
    rotation = reset_rotation
    target_rotation = rotation

func disable():
    hide()
    collider.disabled = true
    freeze = true

func enable():
    freeze = false
    collider.disabled = false
    show()


func get_mouse_world_position(z_depth: float = 1) -> Vector3:
    var viewport = get_viewport()
    var mouse_position = viewport.get_mouse_position()
    var camera = viewport.get_camera_3d()
    return camera.project_position(mouse_position, z_depth)


func _get_can_place() -> bool:
    return placement_grid.contains_point(global_position)

func _on_mouse_entered():
    contains_mouse = true
    if !held: set_colour(colour_hovered)

func _on_mouse_exited():
    contains_mouse = false
    if !held: set_colour(colour_normal)
