class_name ResponseBuilder
extends Node3D

@export var placement_grid: PlacementGrid
@export var fragment_spawner: ResponseFragmentSpawner


func reset() -> void:
    placement_grid.reset()
    fragment_spawner.reset()


func get_response_values() -> ResponseValues:
    var values := ResponseValues.new()
    for placed_fragment in placement_grid.placed_fragments:
        values.add(placed_fragment.fragment)
    return values


class ResponseValues:
    var chastity: int = 0
    var temperance: int = 0
    var humility: int = 0
    var patience: int = 0

    func add(fragment: ResponseFragment):
        chastity += fragment.chastity
        temperance += fragment.temperance
        humility += fragment.humility
        patience += fragment.patience
