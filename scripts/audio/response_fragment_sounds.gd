extends AudioClipPlayer

@export var mouseover: AudioStream
@export var grab: AudioStream
@export var drop: AudioStream

func _ready() -> void:
    var fragment_body: ResponseFragmentBody = get_parent()
    connect_clip(fragment_body.mouse_entered, mouseover)
    connect_clip(fragment_body.grabbed, grab)
    connect_clip(fragment_body.dropped, drop)