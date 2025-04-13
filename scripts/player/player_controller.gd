extends CharacterBody3D

@export var camera: Camera3D
@export var movement_speed: float = 6.0
@export var look_speed := Vector2(2, 1)
@export var minimum_look_angle: float = -PI/8
@export var maximum_look_angle: float = PI/8


func _physics_process(delta: float) -> void:
    move()
    look(delta)
    move_and_slide()


func move():
    velocity *= Vector3.UP
    var input_direction = Input.get_vector(
        "left", "right", "backward", "forward"
    )
    velocity -= input_direction.y * basis.z * movement_speed
    velocity += input_direction.x * basis.x * movement_speed
    velocity += get_gravity()


func look(delta: float):
    var mouse_delta = Input.get_last_mouse_velocity()
    var look_delta = mouse_delta * look_speed * delta / 100
    transform = transform.rotated_local(Vector3.UP, -look_delta.x)
    camera.rotation.x = clampf(
        camera.rotation.x - look_delta.y,
        minimum_look_angle, maximum_look_angle
    )
