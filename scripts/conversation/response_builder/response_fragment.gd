class_name ResponseFragment
extends Resource

const base_material: ShaderMaterial = preload(
    "res://resources/materials/response_fragment_material.tres"
)

@export var title: String
@export var shape_texture: Texture2D
@export var mesh: Mesh
@export var colour := Color.SKY_BLUE

@export_subgroup("stat values")
@export var chastity: int = 0
@export var temperance: int = 0
@export var humility: int = 0
@export var patience: int = 0

@export_subgroup("response snippets", "response_action")
@export_multiline var response_action_chastity: String
@export_multiline var response_action_temperance: String
@export_multiline var response_action_humility: String
@export_multiline var response_action_patience: String

var collider_shape: Shape3D = null


func create_mesh_instance() -> MeshInstance3D:
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = mesh
    return mesh_instance

func create_material_proxy() -> FragmentMaterialProxy:
    var material := FragmentMaterialProxy.new(base_material)
    material.set_colour(colour)
    material.set_edge_offsets(shape_texture.get_size())
    return material

func create_material() -> ShaderMaterial:
    return create_material_proxy().material

func create_collision_shape() -> CollisionShape3D:
    var collision_shape = CollisionShape3D.new()
    collision_shape.shape = get_or_create_collider_shape()
    return collision_shape

func get_or_create_collider_shape() -> Shape3D:
    if collider_shape == null: 
        collider_shape = mesh.create_convex_shape(true, true)
    return collider_shape

func create_and_cache_collider_shape() -> Shape3D:
    collider_shape = mesh.create_convex_shape(true, true)
    return collider_shape



class FragmentMaterialProxy:
    var material: ShaderMaterial

    func _init(base_material: ShaderMaterial):
        material = base_material.duplicate()

    func set_colour(colour: Color):
        material.set_shader_parameter("albedo_colour", colour)

    func set_edge_offsets(fragment_size: Vector2i):
        material.set_shader_parameter("edge_offset_x",
            0.5 if fragment_size.x % 2 != 0 else 0.0
        )
        material.set_shader_parameter("edge_offset_y",
            0.5 if fragment_size.y % 2 != 0 else 0.0
        )
