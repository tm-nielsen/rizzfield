extends AudioClipPlayer

@export var placed: AudioStream
@export var rejected: AudioStream

func _ready() -> void:
    var placement_grid: PlacementGrid = get_parent()
    connect_clip(placement_grid.placements_modified, placed)
    connect_clip(placement_grid.placement_rejected, rejected)