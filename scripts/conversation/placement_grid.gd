@tool
extends MultiMeshInstance3D

@export var grid_size := Vector2i(5, 5)
@export var cell_size: float = 0.1
@export var grid_gap: float = 0.01
@export_tool_button("generate cells") var generate_button = create_grid

@export var test_fragment: ResponseFragment

var cell_count: int
var grid_origin: Vector3
var grid_step: float


func _ready() -> void:
    create_grid()
    test_fragment.initialize()

func _process(_delta: float) -> void:
    for i in cell_count:
        toggle_cell_colour(i, false)

    var viewport = get_viewport()
    var mouse_position = viewport.get_mouse_position()
    var camera = viewport.get_camera_3d()
    var mouse_world_position = camera.project_position(mouse_position, 1)
    
    # var shape_origin = test_fragment.origin
    # var shape_offset = Vector3(shape_origin.x, 0, shape_origin.y) * grid_step
    # var shape_position = mouse_world_position + shape_offset
    if contains_point(mouse_world_position):
        var origin_coords = get_cell_coords(mouse_world_position)
        for cell_offset in test_fragment.cells:
            toggle_cell_colourv(origin_coords + cell_offset)


func get_cell_position(x: int, y: int) -> Vector3:
    return grid_origin + Vector3(x, 0, y) * grid_step

func get_cell_index(cell_coords: Vector2i) -> int:
    return cell_coords.y + grid_size.y * cell_coords.x

func get_cell_index_from_point(point: Vector3) -> int:
    return get_cell_index(get_cell_coords(point))

func get_cell_coords(point: Vector3) -> Vector2i:
    return clamp(
        _get_unclamped_cell_coords(point),
        Vector2i.ZERO, grid_size
    )

func _get_unclamped_cell_coords(point: Vector3) -> Vector2i:
    var offset = (point - grid_origin) / grid_step
    return Vector2i(round(offset.x), round(offset.z))

func contains_point(point: Vector3) -> bool:
    var unclamped_coords = _get_unclamped_cell_coords(point)
    var coords_rect = Rect2i(Vector2i.ZERO, grid_size)
    return coords_rect.has_point(unclamped_coords)


func toggle_cell_colour(cell_index: int, on: bool = true) -> void:
    if cell_index < 0 || cell_index >= cell_count: return
    var cell_colour = Color.WHITE if on else Color.BLACK
    multimesh.set_instance_color(cell_index, cell_colour)

func toggle_cell_colourv(cell_coords: Vector2i, on: bool = true) -> void:
    toggle_cell_colour(get_cell_index(cell_coords), on)


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
    grid_origin = Vector3(origin_2d.x, 0, origin_2d.y)
