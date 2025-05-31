extends Node3D

@export_range(0, 1) var volume: float = 1
@export var fade_duration: float = 3
@export var bus_name: StringName = "Room Tones"
@export var bus_fade_duration: float = 1

var fade_out_tween: Tween
var fade_in_tween: Tween
var active_tone: AudioStreamPlayer

var bus_fade_tween: Tween
var bus_index: int


func _ready() -> void:
    bus_index = AudioServer.get_bus_index(bus_name)
    GameModeSignalBus.conversation_started.connect(tween_bus_volume.bind(0))
    GameModeSignalBus.conversation_ended.connect(tween_bus_volume.bind(1))

    for child in get_children():
        var tone_player: AudioStreamPlayer = child.get_child(0)
        tone_player.volume_linear = 0
        child.body_entered.connect(
            func(body):
            if !body is PlayerController: return
            set_active_room_tone(tone_player)
        )

func set_active_room_tone(source: AudioStreamPlayer):
    if fade_out_tween: fade_out_tween.custom_step(fade_duration)
    if active_tone: fade_out_tween = tween_volume(active_tone, 0)
    if fade_in_tween: fade_in_tween.kill()
    fade_in_tween = tween_volume(source, 1)
    active_tone = source

func tween_volume(
    source: AudioStreamPlayer,
    final_volume: float
) -> Tween:
    var fade_tween = create_tween()
    fade_tween.tween_property(
        source, "volume_linear", final_volume, fade_duration
    )
    return fade_tween


func tween_bus_volume(final_volume: float):
    if bus_fade_tween: bus_fade_tween.kill()
    bus_fade_tween = create_tween()
    var current_volume = AudioServer.get_bus_volume_linear(bus_index)
    bus_fade_tween.tween_method(
        _set_bus_volume, current_volume, final_volume, bus_fade_duration
    )

func _set_bus_volume(bus_volume: float):
    AudioServer.set_bus_volume_linear(bus_index, bus_volume)
