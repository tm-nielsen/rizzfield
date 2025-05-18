extends Area3D

@export var fragment: ResponseFragment
@export var mesh_scale: float = 0.2

@export_subgroup("animation")
@export var spin_speed: float = 2
@export var bob_frequency: float = 2
@export var bob_amplitude: float = 0.15

var mesh: MeshInstance3D


func _ready() -> void:
    body_entered.connect(func(body: PhysicsBody3D):
        if !body is PlayerController: return
        ExplorationSignalBus.notify_fragment_collected(fragment)
        queue_free()
    )
    mesh = fragment.create_mesh_instance()
    mesh.material_override = fragment.create_material()
    add_child(mesh)
    mesh.scale = Vector3.ONE * mesh_scale


func _process(delta: float) -> void:
    if !mesh: return;
    mesh.rotate_y(spin_speed * delta)
    mesh.position.y = sin(
        bob_frequency * Time.get_ticks_msec() / 1000
    ) * bob_amplitude
