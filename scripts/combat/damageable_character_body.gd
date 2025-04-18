class_name DamageableCharacterBody3D
extends CharacterBody3D

enum State {
    TRACKING, ATTACKING, DAMAGED, DEAD
}
const TRACKING = State.TRACKING
const ATTACKING = State.ATTACKING
const DAMAGED = State.DAMAGED
const DEAD = State.DEAD

@export var maximum_health: int = 4

@export_subgroup("flinch", "flinch")
@export var flinch_colour := Color.WHITE
@export var flinch_duration: float = 0.08

@export var surface_material: ShaderMaterial

@onready var health: int = maximum_health
@onready var default_emission: Color \
= surface_material.get_shader_parameter("emission")

var state: State


func receive_damage(damage: int, force: Vector3):
    health -= damage
    start_flinch()
    if health <= 0: die(force)


func start_flinch():
    set_material_emission(flinch_colour)
    var flinch_tween = create_tween()
    flinch_tween.tween_interval(flinch_duration)
    flinch_tween.tween_callback(end_flinch.bind(state))

func end_flinch(previous_state):
    if state != DEAD: state = previous_state
    set_material_emission(default_emission)

func die(_force: Vector3): pass


func set_material_emission(emission: Color):
    surface_material.set_shader_parameter(
        "emission", emission
    )
