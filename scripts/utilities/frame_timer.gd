class_name FrameTimer
extends Node

signal frame_out()

@export var limit_frames: bool = true
@export_range(12, 24) var frame_rate: float = 12.0

var frame_period: float
var frame_timer: float = 0.0


func _process(delta: float) -> void:
    if !limit_frames: frame_out.emit(); return

    frame_timer += delta
    frame_period = 1 / frame_rate
    if frame_timer > frame_period:
        frame_timer -= frame_period
        frame_out.emit()


func pause_for(seconds: float):
    frame_timer -= seconds
