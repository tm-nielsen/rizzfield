class_name ResponseBuilder
extends Node3D

@export var placement_grid: PlacementGrid
@export var fragment_spawner: ResponseFragmentSpawner


func reset() -> void:
    placement_grid.reset()
    fragment_spawner.reset()
