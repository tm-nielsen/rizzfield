class_name ResponseFragmentSpawner
extends Node3D

signal fragment_spawned(fragment: ResponseFragmentBody)

@export var grid: PlacementGrid
@export var fragment_body_prefab: PackedScene
@export var fragments: Array[ResponseFragment]

@export_subgroup("placement")
@export var spawn_area_height: float = 4
@export var position_randomization: float = 1
@export var fragment_count: int = 3


func _ready() -> void:
    fragment_spawned.connect(grid._on_fragment_body_spawned)
    for i in fragment_count:
        spawn_fragment(i)


func spawn_fragment(index: int) -> void:
    var spawn_position = get_spawn_position(index)
    var new_fragment = fragment_body_prefab.instantiate()
    new_fragment.position = grid.xy_to_xz(spawn_position) * basis
    new_fragment.fragment = fragments.pick_random()
    add_child(new_fragment)
    connect_fragment_signals(new_fragment, index)
    fragment_spawned.emit(new_fragment)

func connect_fragment_signals(fragment: ResponseFragmentBody, index: int):
    var spawn_replacement = spawn_fragment.bind(index)
    fragment.placed.connect(spawn_replacement, ConnectFlags.CONNECT_ONE_SHOT)
    fragment.freed.connect(spawn_replacement, ConnectFlags.CONNECT_ONE_SHOT)


func get_spawn_position(index: int) -> Vector2:
    var half_count = (fragment_count - 1) / 2.0
    var index_offset = (index - half_count) / half_count
    var spawn_position = Vector2.ZERO
    spawn_position.y = spawn_area_height * index_offset
    return spawn_position + Vector2(
        randf() * position_randomization,
        randf() * position_randomization
    )
