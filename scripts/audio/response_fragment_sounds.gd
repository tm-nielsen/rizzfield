extends AudioClipPlayer3D

@export var mouseover: AudioStream
@export var grab: AudioStream
@export var drop: AudioStream

func _ready() -> void:
    var fragment_body: ResponseFragmentBody = get_parent()
    fragment_body.mouse_entered.connect(
        func():
        if fragment_body.state != fragment_body.HELD:
            play_clip(mouseover)
    )
    connect_clip(fragment_body.grabbed, grab)
    connect_clip(fragment_body.dropped, drop)