extends Node

@export var main_track: AudioStreamPlayer
@export var delayed_loop: AudioStreamPlayer
@export var loop_delay: float = 135
@export var fade_duration: float = 1
@export var bus_name: StringName = "Music"
@export var bus_fade_duration: float = 2.0

var bus_index: int
var loop_start_tween: Tween


func _ready() -> void:
    bus_index = AudioServer.get_bus_index(bus_name)
    tween_bus_volume(0, 1)

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


func tween_bus_volume(start_volume: float, final_volume: float):
    var bus_fade_tween := create_tween()
    bus_fade_tween.tween_method(
        _set_bus_volume, start_volume, final_volume, bus_fade_duration
    )

func _set_bus_volume(bus_volume: float):
    AudioServer.set_bus_volume_linear(bus_index, bus_volume)
