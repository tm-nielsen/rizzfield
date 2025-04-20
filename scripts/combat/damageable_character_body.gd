class_name DamageableCharacterBody3D
extends CharacterBody3D

signal damaged(amount: int, impact: Vector3)
signal damage_parried
signal damage_blocked

const IDLE = 0
const DAMAGED = 1
const STUNNED = 2
const DEAD = 3

@export var maximum_health: int = 4
@export var block_reduction: int = 1

@export_subgroup("flinch", "flinch")
@export var flinch_colour := Color.WHITE
@export var flinch_duration: float = 0.08

@export var surface_material: ShaderMaterial
@export var blocking: bool = false
@export var parry_window_active: bool = false

@onready var health: int = maximum_health
@onready var default_emission: Color \
= surface_material.get_shader_parameter("emission")

var state: int
var end_flinch_tween: Tween


func receive_damage(amount: int, impact: Vector3):
    if parry_window_active:
        damage_parried.emit()
    else:
        if blocking:
            amount -= block_reduction
            damage_blocked.emit()
            if amount <= 0: return
        health -= amount
        start_flinch()
        if health <= 0: die(impact)
        damaged.emit(amount, impact)


func start_flinch():
    set_material_emission(flinch_colour)
    _end_flinch_in(flinch_duration, state)
    state = DAMAGED

func _end_flinch_in(seconds: float, end_state := state):
    if end_flinch_tween: end_flinch_tween.kill()
    end_flinch_tween = create_tween()
    end_flinch_tween.tween_interval(seconds)
    end_flinch_tween.tween_callback(end_flinch.bind(end_state))

func end_flinch(previous_state: int):
    if state != DEAD: state = previous_state
    set_material_emission(default_emission)

func die(_force: Vector3): pass


func set_material_emission(emission: Color):
    surface_material.set_shader_parameter(
        "emission", emission
    )
