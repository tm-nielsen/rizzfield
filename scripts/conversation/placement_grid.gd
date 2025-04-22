@tool
extends MultiMeshInstance3D

@export var grid_size := Vector2i(5, 5)
@export var cell_size: float = 0.1
@export var grid_gap: float = 0.01

@export_tool_button("generate cells") var generate_button = create_grid
var grid_origin: Vector3
var grid_step: float


func _ready() -> void:
    create_grid()


func get_cell_position(x: int, y: int) -> Vector3:
    return grid_origin + Vector3(x, 0, y) * grid_step

func get_cell_coords(point: Vector3) -> Vector2i:
    return clamp(
        _get_unclamped_cell_coords(point),
        Vector2i.ZERO, grid_size
    )

func _get_unclamped_cell_coords(point: Vector3) -> Vector2i:
    var offset = (point - grid_origin) / grid_step
    return Vector2i(roundi(offset.x), roundi(offset.z))

func contains_point(point: Vector3) -> bool:
    var unclamped_coords = _get_unclamped_cell_coords(point)
    var coords_rect = Rect2i(Vector2i.ZERO, grid_size)
    return coords_rect.has_point(unclamped_coords)


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
            index += 1

func _initialize_multimesh():
    multimesh = MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.instance_count = grid_size.x * grid_size.y

func _initialize_mesh():
    var cell_mesh := PlaneMesh.new()
    cell_mesh.size = Vector2(cell_size, cell_size)
    multimesh.mesh = cell_mesh

func _calculate_grid_origin():
    grid_step = cell_size + grid_gap
    var origin_2d = -grid_step * (grid_size - Vector2i.ONE) / 2.0
    grid_origin = Vector3(origin_2d.x, 0, origin_2d.y)
