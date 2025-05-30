extends Area3D

@export var fragment: ResponseFragment
@export_multiline var description: String
@export var mesh_scale: float = 0.2
@export var audio_source: AudioStreamPlayer3D

@export_subgroup("animation")
@export var spin_speed: float = 2
@export var bob_frequency: float = 2
@export var bob_amplitude: float = 0.15
@export var frame_timer: FrameTimer

var mesh: MeshInstance3D


func _ready() -> void:
    body_entered.connect(
        func(body: PhysicsBody3D):
        if body is PlayerController: collect()
    )
    frame_timer.frame_out.connect(update_mesh_rotation)
    mesh = fragment.create_mesh_instance()
    mesh.material_override = fragment.create_material()
    add_child(mesh)
    mesh.scale = Vector3.ONE * mesh_scale


func collect():
    ExplorationSignalBus.notify_fragment_collected(
        fragment, description
    )
    audio_source.reparent(get_parent())
    audio_source.finished.connect(audio_source.queue_free)
    audio_source.play()
    queue_free()


func update_mesh_rotation() -> void:
    if !mesh: return
    mesh.rotate_y(spin_speed * frame_timer.frame_period)
    mesh.position.y = sin(
        bob_frequency * Time.get_ticks_msec() / 1000
    ) * bob_amplitude
