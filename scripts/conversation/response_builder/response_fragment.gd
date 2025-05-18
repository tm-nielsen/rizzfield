class_name ResponseFragment
extends Resource

@export var shape_texture: Texture2D
@export var mesh: Mesh
@export var base_material: ShaderMaterial
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


func create_mesh_instance() -> MeshInstance3D:
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = mesh
    return mesh_instance

func create_collision_shape() -> CollisionShape3D:
    var collision_shape = CollisionShape3D.new()
    collision_shape.shape = mesh.create_convex_shape(true, true)
    return collision_shape
