extends Node

@export var main_track: AudioStreamPlayer
@export var delayed_loop: AudioStreamPlayer
@export var loop_delay: float = 135
@export var fade_duration: float = 1

var loop_start_tween: Tween


func _ready() -> void:
    loop_start_tween = create_tween()
    loop_start_tween.tween_interval(loop_delay)
    loop_start_tween.tween_callback(delayed_loop.play)

    GameModeSignalBus.game_started.connect(
        func():
        if loop_start_tween: loop_start_tween.kill()
        fade_source(main_track)
        fade_source(delayed_loop)
    )


func fade_source(source: AudioStreamPlayer) -> void:
    var fade_tween = create_tween()
    fade_tween.tween_property(
        source, "volume_linear", 0, fade_duration
    )
