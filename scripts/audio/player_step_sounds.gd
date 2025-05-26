extends LayeredRandomSoundPlayer

@export var movement_body: PlayerController
@export var volume_curve: Curve
@export var step_period: float = 1

var step_timer: float


func _process(delta: float) -> void:
    set_volume(
        volume_curve.sample(
            movement_body.get_normalized_speed()
        )
    )

    step_timer += delta
    if step_timer > step_period:
        step_timer -= step_period
        play()
