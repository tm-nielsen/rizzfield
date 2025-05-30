extends AudioClipPlayer

@export var mouseover: AudioStream
@export var grab: AudioStream
@export var drop: AudioStream

func _ready() -> void:
    var brick: PlaceableBrick = get_parent()
    brick.mouse_entered.connect(
        func(): if !brick.held: play_clip(mouseover)
    )
    connect_clip(brick.grabbed, grab)
    connect_clip(brick.dropped, drop)
