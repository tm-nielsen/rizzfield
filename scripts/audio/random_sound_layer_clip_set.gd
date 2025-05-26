class_name RandomSoundLayerClipSet
extends Resource

@export_range(0, 1) var volume: float = 1
@export var clips: Array[AudioStream]

func pick() -> AudioStream:
    return clips.pick_random()