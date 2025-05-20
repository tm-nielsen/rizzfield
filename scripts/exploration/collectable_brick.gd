extends RigidBody3D

@export var pickup_area: Area3D


func _ready() -> void:
    pickup_area.body_entered.connect(
        func(body: PhysicsBody3D):
        if !body is PlayerController: return
        ExplorationSignalBus.notify_brick_collected()
        queue_free()
    )
