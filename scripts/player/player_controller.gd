class_name PlayerController
extends CharacterBody3D

signal started_moving
signal stopped_moving

@export var move_force: float = 10.0
@export_range(0, 1) var friction: float = 0.04
@export var maximum_speed: float = 4.0

@export var head_node: Node3D
@export var look_speed := Vector2(2, 1)
@export var minimum_look_angle: float = -PI/8
@export var maximum_look_angle: float = PI/8

var is_moving: bool
var was_moving_last_update: bool

# TODO: limit movement during windup, stop movement during swing

func _physics_process(delta: float) -> void:
    look(delta)
    move(delta)
    if is_on_floor(): apply_friction(delta)
    limit_planar_velocity()
    move_and_slide()


func look(delta: float):
    var mouse_delta = Input.get_last_mouse_velocity()
    var look_delta = mouse_delta * look_speed * delta / 100
    transform = transform.rotated_local(Vector3.UP, -look_delta.x)
    head_node.rotation.x = clampf(
        head_node.rotation.x - look_delta.y,
        minimum_look_angle, maximum_look_angle
    )


func move(delta):
    var input_direction = Input.get_vector(
        "left", "right", "backward", "forward"
    )
    was_moving_last_update = is_moving
    is_moving = !input_direction.is_zero_approx()
    if is_moving && !was_moving_last_update:
        started_moving.emit()
    elif !is_moving && was_moving_last_update:
        stopped_moving.emit()

    var input_force = Vector3(input_direction.x, 0, -input_direction.y)
    input_force *= move_force * delta
    velocity += basis * input_force
    
    velocity += get_gravity()


func apply_friction(delta):
    var delta_scale = delta * Engine.physics_ticks_per_second
    velocity.x = ElasticValue.apply_friction(velocity.x, friction, delta_scale)
    velocity.z = ElasticValue.apply_friction(velocity.z, friction, delta_scale)

func limit_planar_velocity():
    var floor_velocity = get_floor_velocity()
    velocity -= floor_velocity
    if floor_velocity.length() > maximum_speed:
        floor_velocity = floor_velocity.normalized() * maximum_speed
    velocity += floor_velocity


func get_normalized_speed() -> float:
    var floor_velocity = get_floor_velocity()
    return floor_velocity.length() / maximum_speed

func get_floor_velocity() -> Vector3:
    var floor_plane = Plane(get_floor_normal())
    return floor_plane.project(velocity)
