class_name ResponseTimer
extends Control

signal timeout

@export var margin: float = 4
@export var drain_curve: Curve
@export var height_tween_duration: float = 0.2

var max_width: float
var display_height: float
var drain_tween: Tween

func _ready() -> void:
    max_width = get_viewport_rect().size.x - margin
    display_height = custom_minimum_size.y
    custom_minimum_size.y = 0
    hide()


func start(duration: float):
    tween_height(0, display_height)
    custom_minimum_size.x = max_width
    drain_tween = create_tween()
    drain_tween.tween_method(_set_width, 1.0, 0.0, duration)
    drain_tween.tween_callback(_end)
    show()

func cancel():
    if drain_tween: drain_tween.kill()
    start_hide_tween()


func start_hide_tween():
    tween_height(
        display_height, 0, Tween.EASE_IN
    ).tween_callback(hide)


func tween_height(
    start_value: float, end_value: float,
    easing := Tween.EASE_OUT
) -> Tween:
    var height_tween = TweenHelpers.build_tween(self, 0, easing)
    height_tween.tween_method(
        _set_height, start_value, end_value,
        height_tween_duration
    )
    return height_tween

func _set_height(height: float):
    custom_minimum_size.y = height

func _set_width(normalized_width: float):
    var curved_width = drain_curve.sample(normalized_width)
    custom_minimum_size.x = max_width * curved_width


func _end():
    start_hide_tween()
    timeout.emit()
