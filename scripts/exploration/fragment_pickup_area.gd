extends Area3D

@export var fragment: ResponseFragment


func _ready() -> void:
    body_entered.connect(func(body: PhysicsBody3D):
        if !body is PlayerController: return
        ExplorationSignalBus.notify_fragment_collected(fragment)
        queue_free()
    )
