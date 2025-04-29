class_name ResponseFragmentBody
extends RigidBody3D

signal grabbed
signal dropped

@export var fragment: ResponseFragment
@export var held_depth: float = 2

var is_held: bool
var contains_mouse: bool

var mesh_instance: MeshInstance3D
var collision_shape = CollisionShape3D


func _ready() -> void:
    mouse_entered.connect(func(): contains_mouse = true)
    mouse_exited.connect(func(): contains_mouse = false)
    mesh_instance = fragment.create_mesh_instance()
    add_child(mesh_instance)
    collision_shape = fragment.create_collision_shape()
    add_child(collision_shape)
    scale_children(0.5)


func _process(_delta) -> void:
    if is_held:
        global_position = get_mouse_world_position(held_depth)
        if Input.is_action_just_released("grab"):
            is_held = false
            freeze = false
            dropped.emit()
    elif contains_mouse && Input.is_action_just_pressed("grab"):
        is_held = true
        freeze = true
        grabbed.emit()


func scale_children(value: float) -> void:
    var child_scale = Vector3.ONE * value
    mesh_instance.scale = child_scale
    collision_shape.scale = child_scale


func get_mouse_world_position(z_depth: float = 1) -> Vector3:
    var viewport = get_viewport()
    var mouse_position = viewport.get_mouse_position()
    var camera = viewport.get_camera_3d()
    return camera.project_position(mouse_position, z_depth)
