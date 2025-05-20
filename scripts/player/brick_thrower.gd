extends Node3D

@export var brick_prefab: PackedScene

@export var spawn_height_offset: float = 0.5
@export var spawn_speed: float = 5
@export var spawn_torque: float = 50
@export var spawn_offset: float = 0.5

var spawn_position: Vector3


func _ready() -> void:
    GameModeSignalBus.conversation_triggered.connect(
        (func(_definition, vignette_instance: Node3D):
        spawn_position = vignette_instance.global_position
        spawn_position.y += spawn_height_offset).call_deferred
    )
    GameModeSignalBus.brick_thrown.connect(spawn_brick.call_deferred)


func spawn_brick():
    var brick: RigidBody3D = brick_prefab.instantiate()
    get_viewport().add_child(brick)
    brick.position = spawn_position
    var spawn_direction = get_spawn_direction()
    brick.apply_impulse(spawn_direction * spawn_speed)
    brick.apply_torque_impulse(
        get_spawn_spin_direction() * spawn_torque
    )
    brick.position += spawn_direction * spawn_offset


func get_spawn_direction() -> Vector3:
    return Vector3.UP.rotated(
        Vector3.RIGHT, randf_range(-PI / 4, PI / 4)
    ).rotated(
        Vector3.FORWARD, randf_range(-PI / 4, PI / 4)
    )

func get_spawn_spin_direction() -> Vector3:
    return Vector3(
        randf_range(-1, 1),
        randf_range(-1, 1),
        randf_range(-1, 1)
    )
