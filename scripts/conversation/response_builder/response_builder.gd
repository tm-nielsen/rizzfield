class_name ResponseBuilder
extends Node3D

signal response_modified(updated_values: ResponseValues)

@export var placement_grid: PlacementGrid
@export var fragment_spawner: ResponseFragmentSpawner

var is_blank: bool: get=_get_is_blank


func _ready() -> void:
    placement_grid.placements_modified.connect(
        func(): response_modified.emit(get_response_values())
    )

func reset() -> void:
    placement_grid.reset()
    fragment_spawner.reset()


func get_response_values() -> ResponseValues:
    var values := ResponseValues.new()
    for placed_fragment in placement_grid.placed_fragments:
        values.add(placed_fragment.fragment)
    return values


func _get_is_blank() -> bool:
    return placement_grid.placed_fragments.is_empty()
