extends CharacterBody3D

@export var camera: Camera3D
@export var movement_speed: float = 10.0


func _physics_process(_delta: float) -> void:
    var input_direction = Input.get_vector(
        "left", "right", "forward", "backward"
    )
    var planar_velocity = input_direction * movement_speed

    velocity.x = planar_velocity.x
    velocity.z = planar_velocity.y
    velocity += get_gravity()

    move_and_slide()
