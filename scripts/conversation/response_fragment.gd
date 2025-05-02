class_name ResponseFragment
extends Resource

@export var name: String
@export var value: int = 1
@export var shape_texture: Texture2D
@export var mesh: Mesh
@export var base_material: ShaderMaterial
@export var colour := Color.SKY_BLUE

var cells: Array[Vector2i]
var size: Vector2i


func initialize():
    var shape_image = shape_texture.get_image()
    size = shape_image.get_size()
    generate_cells(shape_image)

func generate_cells(shape_image: Image):
    cells = []
    for x in size.x: for y in size.y:
        if shape_image.get_pixel(x, y).v > 0.5:
            cells.append(Vector2i(x, y))


func create_mesh_instance() -> MeshInstance3D:
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = mesh
    return mesh_instance

func create_collision_shape() -> CollisionShape3D:
    var collision_shape = CollisionShape3D.new()
    collision_shape.shape = mesh.create_convex_shape(true, true)
    return collision_shape
