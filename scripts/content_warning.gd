extends Control

static var has_been_shown: bool = false

@export var duration: float = 5
@export var skip_enable_delay: float = 1
@export var next_screen: Control

var hide_tween: Tween
var skip_timer: float


func _ready() -> void:
    if has_been_shown:
        end_display()
    else:
        next_screen.hide()
        show()
        hide_tween = create_tween()
        hide_tween.tween_interval(duration)
        hide_tween.tween_callback(end_display)

func _process(delta: float) -> void:
    skip_timer += delta
    if (
        skip_timer > skip_enable_delay &&
        Input.is_anything_pressed()
    ):
        hide_tween.kill()
        end_display()


func end_display():
    has_been_shown = true
    next_screen.show()
    queue_free()
