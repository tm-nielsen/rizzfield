extends Area3D

@export var fragment: ResponseFragment

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
    for child in get_children():
        if child is MeshInstance3D:
            mesh = child
            mesh.mesh = fragment.mesh


func _process(delta: float) -> void:
    if !mesh: return;
    mesh.rotate_y(spin_speed * delta)
    mesh.position.y = sin(
        bob_frequency * Time.get_ticks_msec() / 1000
    ) * bob_amplitude
