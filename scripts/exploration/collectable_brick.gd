extends RigidBody3D

@export var pickup_area: Area3D
@export var audio_source: AudioStreamPlayer3D


func _ready() -> void:
    pickup_area.body_entered.connect(
        func(body: PhysicsBody3D):
        if !body is PlayerController: return
        ExplorationSignalBus.notify_brick_collected()
        audio_source.reparent(get_parent())
        audio_source.finished.connect(audio_source.queue_free)
        audio_source.play()
        queue_free()
    )
