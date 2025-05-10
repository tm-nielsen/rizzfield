class_name ResponseTimer
extends Control

signal timeout

@export var duration: float = 8
@export var margin: float = 4
@export var drain_curve: Curve

@onready var max_width: float
var drain_tween: Tween

func _ready() -> void:
    max_width = get_viewport_rect().size.x - margin
    hide()


func start():
    custom_minimum_size.x = max_width
    drain_tween = create_tween()
    drain_tween.tween_method(_set_value, 1.0, 0.0, duration)
    drain_tween.tween_callback(_end)
    show()

func _set_value(t: float):
    custom_minimum_size.x = max_width * drain_curve.sample(t)

func _end():
    hide()
    timeout.emit()
