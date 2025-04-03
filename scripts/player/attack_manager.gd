extends Node3D

enum AttackState {IDLE, CHARGING, CHARGED, SWINGING}

@export var animator: AnimationPlayer

var state: AttackState


func _ready() -> void:
    animator.animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void:
    var charge_pressed = Input.is_action_pressed("attack")

    match state:
        AttackState.IDLE:
            if charge_pressed: animator.play("charge")
        AttackState.CHARGED:
            if !charge_pressed: animator.play("swing")


func _on_animation_finished(animation_name: String):
    match animation_name:
        "charge":
            animator.play("hold_charge")
            state = AttackState.CHARGED
        "swing":
            animator.play("idle")
            state = AttackState.IDLE
