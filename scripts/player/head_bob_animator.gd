extends Node3D

@export var movement_body: PlayerController
@export var update_timer: FrameTimer
@export var amplitude := Vector2(0.1, 0.1)
@export var frequency: float = 1.0


func _ready() -> void:
    update_timer.frame_out.connect(update_position)


func update_position():
    var s := 0.0
    if movement_body.is_on_floor():
        s = movement_body.get_normalized_speed()

    var t = Time.get_ticks_msec() * frequency / 1000
    position.x = cos(t * TAU) * amplitude.x * s
    position.y = sin(t * TAU * 2) * amplitude.y * s