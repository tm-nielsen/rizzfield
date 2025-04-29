class_name ResponseFragmentBody
extends RigidBody3D

signal grabbed
signal dropped

enum State {FREE, HELD, PLACED}
const FREE = State.FREE
const HELD = State.HELD
const PLACED = State.PLACED

@export var fragment: ResponseFragment
@export var held_depth: float = 2

@export_subgroup("colours", "colour")
@export var colour_hovered := Color.WHITE
@export var colour_grabbed := Color.DIM_GRAY
@export var colour_placed := Color.WEB_GREEN

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
    scale_children(0.5)


func _process(_delta) -> void:
    if state == HELD:
        if Input.is_action_just_released("grab"):
            state = FREE
            freeze = false
            set_colour(colour_hovered if contains_mouse else fragment.colour)
            dropped.emit()
        else:
            global_position = get_mouse_world_position(held_depth)
    elif contains_mouse && Input.is_action_just_pressed("grab"):
        state = HELD
        freeze = true
        set_colour(colour_grabbed)
        grabbed.emit()


func place_and_freeze(point: Vector3):
    position = point
    freeze = true
    set_colour(colour_placed)


func scale_children(value: float) -> void:
    var child_scale = Vector3.ONE * value
    mesh_instance.scale = child_scale
    collision_shape.scale = child_scale


func set_colour(colour: Color) -> void:
    material.set_shader_parameter("albedo_colour", colour)


func get_mouse_world_position(z_depth: float = 1) -> Vector3:
    var viewport = get_viewport()
    var mouse_position = viewport.get_mouse_position()
    var camera = viewport.get_camera_3d()
    return camera.project_position(mouse_position, z_depth)


func _on_mouse_entered():
    contains_mouse = true
    if state == FREE || state == PLACED:
        set_colour(colour_hovered)

func _on_mouse_exited():
    contains_mouse = false
    match state:
        FREE: set_colour(fragment.colour)
        PLACED: set_colour(colour_placed)
