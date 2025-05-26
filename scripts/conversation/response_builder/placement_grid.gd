@tool
class_name PlacementGrid
extends MultiMeshInstance3D

signal placements_modified
signal placement_rejected

@export var grid_size := Vector2i(5, 5)
@export var cell_size: float = 0.1
@export var grid_gap: float = 0.01
@export_tool_button("generate cells") var generate_button = create_grid

@export_subgroup("colours", "colour")
@export var colour_available := Color.BLACK
@export var colour_filled := Color.GRAY
@export var colour_highlight := Color.WHITE
@export var colour_error := Color.RED

var held_fragment: PlacedResponseFragment
var placed_fragments: Array[PlacedResponseFragment] = []

var cell_count: int
var grid_origin: Vector3
var grid_step: float


func _ready() -> void:
    create_grid()

func reset() -> void:
    held_fragment = null
    placed_fragments = []

func _process(_delta: float) -> void:
    if Engine.is_editor_hint(): return

    for i in cell_count:
        set_cell_colour(i)

    for fragment in placed_fragments:
        paint_fragment(fragment)

    if held_fragment:
        held_fragment.process_input()
        update_held_fragment_origin()
        held_fragment.update_body_colour(
            overlaps_held_fragment_shape(),
            is_held_fragment_placeable()
        )
        paint_held_fragment()

func paint_held_fragment():
    var fill_colour = colour_highlight
    if !is_held_fragment_placeable():
        fill_colour = colour_error
    paint_fragment(held_fragment, fill_colour)


func get_cell_position(x: int, y: int) -> Vector3:
    return grid_origin + Vector3(x, 0, y) * grid_step

func get_cell_positionv(cell_coords: Vector2i) -> Vector3:
    return get_cell_position(cell_coords.x, cell_coords.y)

func get_cell_index(cell_coords: Vector2i) -> int:
    if !contains_coords(cell_coords): return -1
    return cell_coords.y + grid_size.y * cell_coords.x

func get_cell_index_from_point(point: Vector3) -> int:
    return get_cell_index(get_cell_coords(point))

func get_cell_coords(point: Vector3) -> Vector2i:
    point -= global_position
    var offset = (point - grid_origin) / grid_step
    return Vector2i(round(offset.x), round(offset.z))

func get__clamped_cell_coords(point: Vector3) -> Vector2i:
    return clamp(
        get_cell_coords(point),
        Vector2i.ZERO, grid_size
    )


func contains_point(point: Vector3) -> bool:
    return contains_coords(get_cell_coords(point))

func contains_coords(cell_coords: Vector2i) -> bool:
    var coords_rect = Rect2i(Vector2i.ZERO, grid_size)
    return coords_rect.has_point(cell_coords)


func is_held_fragment_placeable() -> bool:
    if !contains_held_fragment_shape(): return false
    return held_fragment.for_all_cells(is_cell_available)

func is_cell_available(cell_coords: Vector2i) -> bool:
    if !contains_coords(cell_coords): return false
    for fragment in placed_fragments:
        if fragment.occupies_cell(cell_coords):
            return false
    return true


func set_cell_colour(cell_index: int, colour := colour_available) -> void:
    if cell_index < 0 || cell_index >= cell_count: return
    multimesh.set_instance_color(cell_index, colour)

func set_cell_colourv(cell_coords: Vector2i, colour := colour_available) -> void:
    set_cell_colour(get_cell_index(cell_coords), colour)

func paint_fragment(fragment: PlacedResponseFragment, colour := colour_filled) -> void:
    fragment.for_each_cell(set_cell_colourv.bind(colour))


func contains_held_fragment_shape() -> bool:
    var mouse_position := get_mouse_world_position()
    var placement_offset := get_fragment_placement_offset(held_fragment)
    var contains_origin := contains_point(mouse_position + placement_offset)
    var contains_end := contains_point(mouse_position - placement_offset)
    return contains_origin && contains_end

func overlaps_held_fragment_shape() -> bool:
    var mouse_position := get_mouse_world_position()
    var placement_offset := get_fragment_placement_offset(held_fragment)
    var contains_origin := contains_point(mouse_position + placement_offset)
    var contains_end := contains_point(mouse_position - placement_offset)
    return contains_origin || contains_end


func update_held_fragment_origin() -> void:
    held_fragment.origin = get_held_fragment_origin_coords()

func get_held_fragment_origin_coords() -> Vector2i:
    var mouse_position = get_mouse_world_position()
    var placement_offset = get_fragment_placement_offset(held_fragment)
    return get_cell_coords(mouse_position + placement_offset)

func get_fragment_placement_offset(fragment: PlacedResponseFragment) -> Vector3:
    var origin_cell_position = fragment.get_origin_cell_centre()
    return xy_to_xz(origin_cell_position) * grid_step

func get_held_fragment_placement_point() -> Vector3:
    var origin_cell_coords = get_held_fragment_origin_coords()
    var placement_point = get_cell_positionv(origin_cell_coords)
    placement_point -= get_fragment_placement_offset(held_fragment)
    placement_point += global_position
    return placement_point


func get_mouse_world_position() -> Vector3:
    var viewport = get_viewport()
    var mouse_position = viewport.get_mouse_position()
    var camera = viewport.get_camera_3d()
    var depth = camera.global_position.y - global_position.y
    return camera.project_position(mouse_position, depth)


func create_grid():
    _initialize_multimesh()
    _initialize_mesh()
    _calculate_grid_origin()

    var index = 0
    for x in grid_size.x:
        for y in grid_size.y:
            multimesh.set_instance_transform(index, Transform3D(
                Basis.IDENTITY, get_cell_position(x, y)
            ))
            multimesh.set_instance_color(index, Color.WHITE)
            index += 1

func _initialize_multimesh():
    multimesh = MultiMesh.new()
    multimesh.instance_count = 0
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.use_colors = true
    cell_count = grid_size.x * grid_size.y
    multimesh.instance_count = cell_count

func _initialize_mesh():
    var cell_mesh := PlaneMesh.new()
    cell_mesh.size = Vector2(cell_size, cell_size)
    multimesh.mesh = cell_mesh

func _calculate_grid_origin():
    grid_step = cell_size + grid_gap
    var origin_2d = -grid_step * (grid_size - Vector2i.ONE) / 2.0
    grid_origin = xy_to_xz(origin_2d)

func xy_to_xz(cell_space_vector: Vector2) -> Vector3:
    return Vector3(cell_space_vector.x, 0, cell_space_vector.y)


func _on_fragment_body_spawned(fragment_body: ResponseFragmentBody):
    fragment_body.grabbed.connect(_on_fragment_body_grabbed.bind(fragment_body))
    fragment_body.dropped.connect(_on_fragment_body_dropped.bind(fragment_body))
    fragment_body.freed.connect(_on_fragment_body_freed.bind(fragment_body))

func _on_fragment_body_freed(fragment_body: ResponseFragmentBody):
    if held_fragment != null && held_fragment.body == fragment_body:
        held_fragment = null
        ResponseBuilderSignalBus.held_fragment_freed.emit()

func _on_fragment_body_grabbed(fragment_body: ResponseFragmentBody):
    held_fragment = PlacedResponseFragment.new(fragment_body)
    var placed_index = placed_fragments.find_custom(held_fragment.shares_body)
    if placed_index != -1:
        placed_fragments.remove_at(placed_index)
        placements_modified.emit()
    var camera = get_viewport().get_camera_3d()
    fragment_body.camera_depth = camera.global_position.y - global_position.y

func _on_fragment_body_dropped(fragment_body: ResponseFragmentBody):
    update_held_fragment_origin()
    if is_held_fragment_placeable():
        placed_fragments.append(held_fragment)
        placements_modified.emit()
        var placement_point = get_held_fragment_placement_point()
        fragment_body.place_and_freeze(placement_point)
    elif overlaps_held_fragment_shape():
        fragment_body.repel(global_position)
        placement_rejected.emit()
    held_fragment = null
