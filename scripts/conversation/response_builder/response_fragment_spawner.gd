class_name ResponseFragmentSpawner
extends Node3D

signal fragment_spawned(fragment: ResponseFragmentBody)

@export var grid: PlacementGrid
@export var fragment_body_prefab: PackedScene
@export var default_fragments: Array[ResponseFragment]

@export_subgroup("placement")
@export var spawn_area_height: float = 4
@export var position_randomization: float = 1
@export var fragment_count: int = 3

var fragments: Array[ResponseFragment]


func _ready() -> void:
    fragment_spawned.connect(grid._on_fragment_body_spawned)
    fragments = default_fragments.duplicate()
    for fragment in fragments: fragment.create_and_cache_collider_shape()
    ExplorationSignalBus.fragment_collected.connect(
        func(fragment: ResponseFragment):
        fragments.append(fragment)
        fragment.create_and_cache_collider_shape()
    )

func reset() -> void:
    for child: ResponseFragmentBody in get_children():
        for connection in child.freed.get_connections():
            child.freed.disconnect(connection.callable)
        child.queue_free()
    spawn_initial_fragments()


func spawn_initial_fragments() -> void:
    for i in fragment_count: spawn_fragment(i)

func spawn_fragment(index: int) -> void:
    var spawn_position = get_spawn_position(index)
    var new_fragment: ResponseFragmentBody = fragment_body_prefab.instantiate()
    new_fragment.position = grid.xy_to_xz(spawn_position) * basis
    new_fragment.fragment = fragments.pick_random()
    add_fragment.call_deferred(new_fragment, index)

func add_fragment(fragment: ResponseFragmentBody, index) -> void:
    add_child(fragment)
    fragment.scale_children(grid.cell_size)
    connect_fragment_signals(fragment, index)
    fragment_spawned.emit(fragment)

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
