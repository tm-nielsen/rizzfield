class_name AudioClipPlayer
extends AudioStreamPlayer3D

func _notification(what: int) -> void:
    if what == NOTIFICATION_ENTER_TREE:
        bus = "Sounds"

func connect_clip(source_signal, clip: AudioStream):
    source_signal.connect(play_clip.bind(clip))

func play_clip(clip: AudioStream):
    stream = clip
    play()