class_name LayeredRandomSoundPlayer3D
extends Node3D

@export_range(0, 1) var volume: float = 1: set = set_volume
@export var layer_streams: Array[AudioStreamRandomizer]

var layer_sources: Array[AudioStreamPlayer3D]

func _ready() -> void:
    for layer in layer_streams:
        var new_source = AudioStreamPlayer3D.new()
        new_source.volume_linear = volume
        new_source.bus = "Sounds"
        new_source.stream = layer
        layer_sources.append(new_source)
        add_child(new_source)

func play(): for source in layer_sources: source.play()


func set_volume(value: float):
    value = clampf(value, 0, 1)
    for source in layer_sources:
        if volume > 0: source.volume_linear = value
