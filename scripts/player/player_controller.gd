class_name PlayerController
extends DamageableCharacterBody3D

signal started_moving
signal stopped_moving

@export_subgroup("moving")
@export var move_force: float = 10.0
@export var maximum_speed: float = 4.0
@export var movement_input_scale: float = 1.0

@export_subgroup("friction")
@export_range(0, 1) var moving_friction: float = 0.04
@export_range(0, 1) var stopped_friction: float = 0.1
@export_range(0, 1) var air_friction: float = 0.01

@export_subgroup("looking")
@export var head_node: Node3D
@export var look_speed := Vector2(2, 1)
@export var minimum_look_angle: float = -PI/8
@export var maximum_look_angle: float = PI/8

var is_moving: bool
var was_moving_last_update: bool


func _ready() -> void:
    GameModeSignalBus.combat_triggered.connect(_on_combat_triggered)
    GameModeSignalBus.conversation_resolved.connect(apply_head_rotation)

func _physics_process(delta: float) -> void:
    look(delta)
    move(delta)
    apply_friction(delta)
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
    input_direction *= movement_input_scale

    was_moving_last_update = is_moving
    is_moving = !input_direction.is_zero_approx()
    if is_moving && !was_moving_last_update:
        started_moving.emit()
    elif !is_moving && was_moving_last_update:
        stopped_moving.emit()

    var input_force = Vector3(input_direction.x, 0, -input_direction.y)
    input_force *= move_force * delta
    velocity += basis * input_force
    
    velocity += get_gravity() * delta


func apply_friction(delta):
    var friction = air_friction
    if is_on_floor():
        if is_moving: friction = moving_friction
        else: friction = stopped_friction

    var delta_scale = delta * Engine.physics_ticks_per_second
    velocity.x = ElasticValue.apply_friction(velocity.x, friction, delta_scale)
    velocity.z = ElasticValue.apply_friction(velocity.z, friction, delta_scale)

func limit_planar_velocity():
    if !is_on_floor(): return
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


func _on_combat_triggered():
    apply_head_rotation()
    receive_damage(1, -basis.z * 10)

func receive_damage(amount: int, impulse: Vector3):
    super(amount, impulse)
    velocity -= impulse

func apply_impulse(impulse: Vector3):
    velocity += basis * impulse

func apply_head_rotation():
    rotation.x = 0
    rotation.y += head_node.rotation.y
    rotation.z = 0
    head_node.rotation.y = 0
    head_node.rotation.z = 0
