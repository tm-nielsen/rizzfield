class_name PlayerController
extends CharacterBody3D

signal started_moving
signal stopped_moving

@export var head_node: Node3D
@export var movement_speed: float = 6.0
@export var look_speed := Vector2(2, 1)
@export var minimum_look_angle: float = -PI/8
@export var maximum_look_angle: float = PI/8

var is_moving: bool
var was_moving_last_update: bool


func _physics_process(delta: float) -> void:
    move()
    look(delta)
    move_and_slide()


func move():
    velocity *= Vector3.UP

    var input_direction = Input.get_vector(
        "left", "right", "backward", "forward"
    )
    was_moving_last_update = is_moving
    is_moving = !input_direction.is_zero_approx()
    if is_moving && !was_moving_last_update:
        started_moving.emit()
    elif !is_moving && was_moving_last_update:
        stopped_moving.emit()

    velocity -= input_direction.y * basis.z * movement_speed
    velocity += input_direction.x * basis.x * movement_speed
    velocity += get_gravity()


func look(delta: float):
    var mouse_delta = Input.get_last_mouse_velocity()
    var look_delta = mouse_delta * look_speed * delta / 100
    transform = transform.rotated_local(Vector3.UP, -look_delta.x)
    head_node.rotation.x = clampf(
        head_node.rotation.x - look_delta.y,
        minimum_look_angle, maximum_look_angle
    )


func get_normalized_speed() -> float:
    return (velocity * Vector3(1, 0, 1)).length() / movement_speed
