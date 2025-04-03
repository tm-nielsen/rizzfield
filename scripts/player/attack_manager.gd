extends Node3D

enum AttackState {IDLE, CHARGING, CHARGED, SWINGING}
var state: AttackState

@export var animator: AnimationPlayer


func _ready() -> void:
    animator.animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void:
    if Input.is_action_pressed("attack"):
        if state == AttackState.IDLE: set_state(AttackState.CHARGING)
    else: match state:
        # AttackState.CHARGING: set_state(AttackState.IDLE)
        AttackState.CHARGED: set_state(AttackState.SWINGING)


func set_state(new_state: AttackState):
    match new_state:
        AttackState.IDLE: animator.play("idle")
        AttackState.CHARGING: animator.play("charge")
        AttackState.CHARGED: animator.play("hold_charge")
        AttackState.SWINGING: animator.play("swing")
    state = new_state


func _on_animation_finished(animation_name: String):
    match animation_name:
        "charge": set_state(AttackState.CHARGED)
        "swing": set_state(AttackState.IDLE)
