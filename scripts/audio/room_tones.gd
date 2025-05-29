extends Node3D

@export_range(0, 1) var volume: float = 1
@export var fade_duration: float = 3

var fade_out_tween: Tween
var fade_in_tween: Tween
var active_tone: AudioStreamPlayer


func _ready() -> void:
    for child in get_children():
        var tone_player: AudioStreamPlayer = child.get_child(0)
        tone_player.volume_linear = 0
        print(child.name, " | ", tone_player.name)
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
