extends Node3D

enum AttackState {
    IDLE, CHARGING, CHARGED,
    STARTING_WEAK_SWING, SWINGING
}
var state: AttackState

@export var animator: AnimationPlayer

var attack_pressed: bool;


func _ready() -> void:
    animator.animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void:
    attack_pressed = Input.is_action_pressed("attack")
    match state:
        AttackState.IDLE:
            if attack_pressed: set_state(AttackState.CHARGING)
        AttackState.CHARGED:
            if !attack_pressed: set_state(AttackState.SWINGING)


func set_state(new_state: AttackState):
    match new_state:
        AttackState.IDLE: animator.play("idle")
        AttackState.CHARGING: animator.play("charge")
        AttackState.CHARGED: animator.play("hold_charge")
        AttackState.STARTING_WEAK_SWING: animator.play("swing_windup")
        AttackState.SWINGING: animator.play("swing")
    state = new_state


func _on_animation_finished(_animation_name: String):
    match state:
        AttackState.CHARGING: 
            if (attack_pressed): set_state(AttackState.CHARGED)
            else: set_state(AttackState.STARTING_WEAK_SWING)
        AttackState.STARTING_WEAK_SWING: set_state(AttackState.SWINGING)
        AttackState.SWINGING: set_state(AttackState.IDLE)
