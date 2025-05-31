extends Area3D

func _ready() -> void:
    body_entered.connect(
        func(body: PhysicsBody3D):
        if body is PlayerController:
            GameModeSignalBus.notify_player_died()
        else:
            body.queue_free()
            if body is DamageableCharacterBody3D: body.died.emit()
    )
