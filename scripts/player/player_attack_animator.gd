class_name PlayerAttackAnimator
extends AnimationPlayer

enum AttackState {
    IDLE, CHARGING, CHARGED,
    STARTING_UNCHARGED_SWING, SWINGING,
    BLOCKING, BLOCK_RECOVERY,
    COUNTER_CHARGED, COUNTER_SWINGING
}
const IDLE = AttackState.IDLE
const CHARGING = AttackState.CHARGING
const CHARGED = AttackState.CHARGED
const STARTING_UNCHARGED_SWING = AttackState.STARTING_UNCHARGED_SWING
const SWINGING = AttackState.SWINGING
const BLOCKING = AttackState.BLOCKING
const BLOCK_RECOVERY = AttackState.BLOCK_RECOVERY
const COUNTER_CHARGED = AttackState.COUNTER_CHARGED
const COUNTER_SWINGING = AttackState.COUNTER_SWINGING

var state: AttackState

@export var movement_body: PlayerController
@export var base_hit_stop_duration: float = 0.08
@export var view_bob_frame_timer: FrameTimer

var attack_pressed: bool
var block_pressed: bool


func _ready() -> void:
    animation_finished.connect(_on_animation_finished)
    movement_body.started_moving.connect(_on_player_movement_started)
    movement_body.stopped_moving.connect(_on_player_movement_ended)

func _process(_delta: float) -> void:
    attack_pressed = Input.is_action_pressed("attack")
    block_pressed = Input.is_action_pressed("block")
    match state:
        IDLE:
            if attack_pressed: set_state(CHARGING)
            elif block_pressed: set_state(BLOCKING)
        CHARGED: if !attack_pressed: set_state(SWINGING)
        BLOCKING: if !block_pressed: set_state(BLOCK_RECOVERY)
        COUNTER_CHARGED: if !block_pressed: set_state(COUNTER_SWINGING)


func set_state(new_state: AttackState):
    match new_state:
        IDLE:
            if movement_body.is_moving:
                play("idle_static")
            else: play("idle")
        CHARGING: play("charge")
        CHARGED: play("hold_charge")
        STARTING_UNCHARGED_SWING: play("swing_windup")
        SWINGING: play("swing")
        BLOCKING: play("block")
        BLOCK_RECOVERY: play("block_recovery")
        COUNTER_CHARGED: play("hold_parry_charge")
        COUNTER_SWINGING: play("parry_swing")
    state = new_state


func _on_damaged_enemy(damage: int):
    pause()
    var pause_duration = base_hit_stop_duration * damage
    view_bob_frame_timer.pause_for(pause_duration)
    var pause_tween = create_tween()
    pause_tween.tween_interval(pause_duration)
    pause_tween.tween_callback(play)

func _on_player_parried():
    set_state(COUNTER_CHARGED)

func _on_animation_finished(_animation_name: String):
    match state:
        CHARGING: 
            if (attack_pressed): set_state(CHARGED)
            else: set_state(STARTING_UNCHARGED_SWING)
        STARTING_UNCHARGED_SWING: set_state(SWINGING)
        SWINGING, BLOCK_RECOVERY, COUNTER_SWINGING: set_state(IDLE)


func _on_player_movement_started():
    if state == IDLE: play("idle_static", 0.5)

func _on_player_movement_ended():
    if state == IDLE: play("idle", 0.5)