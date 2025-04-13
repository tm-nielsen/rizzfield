extends Node3D

@export var movement_body: CharacterBody3D
@export var amplitude := Vector2(0.1, 0.1)
@export var frequency: float = 1.0
@export_range(12, 24) var framerate: float = 12.0

var frame_timer: float = 0.0


func _physics_process(delta: float) -> void:
    frame_timer += delta
    if frame_timer > 1 / framerate:
        frame_timer -= 1 / framerate
        update_position()


func update_position():
    var t = Time.get_ticks_msec() * frequency / 1000
    position.x = cos(t * TAU) * amplitude.x
    position.y = sin(t * TAU * 2) * amplitude.y