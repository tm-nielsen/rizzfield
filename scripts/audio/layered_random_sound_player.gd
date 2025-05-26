class_name LayeredRandomSoundPlayer
extends Node3D

@export_range(0, 1) var volume: float = 1
@export var layer_clip_sets: Array[RandomSoundLayerClipSet]

var layer_sources: Array[AudioStreamPlayer3D]
var layer_count: int


func _ready() -> void:
    layer_count = layer_clip_sets.size()
    for layer in layer_clip_sets:
        var new_source = AudioStreamPlayer3D.new()
        new_source.volume_linear = volume * layer.volume
        new_source.bus = "Sounds"
        add_child(new_source)

func play():
    for i in layer_count:
        var source = layer_sources[i]
        source.clip = layer_clip_sets[i].pick()
        source.play()