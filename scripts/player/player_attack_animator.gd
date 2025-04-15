extends AnimationPlayer

signal started_charging
signal finished_charging
signal started_uncharged_swing
signal started_charged_swing

enum AttackState {
    IDLE, CHARGING, CHARGED,
    STARTING_UNCHARGED_SWING, SWINGING
}
const IDLE = AttackState.IDLE
const CHARGING = AttackState.CHARGING
const CHARGED = AttackState.CHARGED
const STARTING_UNCHARGED_SWING = AttackState.STARTING_UNCHARGED_SWING
const SWINGING = AttackState.SWINGING

var state: AttackState

@export var movement_body: PlayerController

var attack_pressed: bool;


func _ready() -> void:
    animation_finished.connect(_on_animation_finished)
    movement_body.started_moving.connect(_on_player_movement_started)
    movement_body.stopped_moving.connect(_on_player_movement_ended)

func _process(_delta: float) -> void:
    attack_pressed = Input.is_action_pressed("attack")
    match state:
        IDLE: if attack_pressed: set_state(CHARGING)
        CHARGED: if !attack_pressed: set_state(SWINGING)


func set_state(new_state: AttackState):
    match new_state:
        IDLE:
            if movement_body.is_moving:
                play("idle_static")
            else: play("idle")
        CHARGING:
            play("charge")
            started_charging.emit()
        CHARGED:
            play("hold_charge")
            finished_charging.emit()
        STARTING_UNCHARGED_SWING:
            play("swing_windup")
            started_uncharged_swing.emit()
        SWINGING:
            play("swing")
            started_charged_swing.emit()
    state = new_state


func _on_animation_finished(_animation_name: String):
    match state:
        CHARGING: 
            if (attack_pressed): set_state(CHARGED)
            else: set_state(STARTING_UNCHARGED_SWING)
        STARTING_UNCHARGED_SWING: set_state(SWINGING)
        SWINGING: set_state(IDLE)


func _on_player_movement_started():
    if state == IDLE: play("idle_static", 0.5)

func _on_player_movement_ended():
    if state == IDLE: play("idle", 0.5)