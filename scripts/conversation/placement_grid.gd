@tool
extends MultiMeshInstance3D

@export var grid_size := Vector2i(5, 5)
@export var cell_size: float = 0.1
@export var grid_gap: float = 0.01

@export_tool_button("generate cells") var generate_button = create_grid


func _ready() -> void:
    create_grid()

func create_grid():
    initialize_mesh()
    multimesh.instance_count = grid_size.x * grid_size.y
    
    var index = 0
    var grid_step = cell_size + grid_gap
    var origin = -grid_step * (grid_size - Vector2i.ONE) / 2.0
    var cell_position := Vector3(origin.x, 0, origin.y)
    for x in grid_size.x:
        for y in grid_size.y:
            multimesh.set_instance_transform(index, Transform3D(
                Basis.IDENTITY, cell_position
            ))
            cell_position.z += cell_size + grid_gap
            index += 1
        cell_position.z = origin.y
        cell_position.x += cell_size + grid_gap

func initialize_mesh():
    multimesh = MultiMesh.new()
    var cell_mesh := PlaneMesh.new()
    cell_mesh.size = Vector2(cell_size, cell_size)
    multimesh.mesh = cell_mesh
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
