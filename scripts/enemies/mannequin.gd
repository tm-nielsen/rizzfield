extends CharacterBody3D

enum State {
    TRACKING, ATTACKING
}
const TRACKING = State.TRACKING
const ATTACKING = State.ATTACKING

@export var animator: AnimationPlayer
@export var step_animator: ProceduralStepAnimator
@export var ragdoll: PhysicalBoneSimulator3D
@export var force_node: PhysicalBone3D

@export_subgroup("behaviour parameters")
@export var target_lead_distance: float = 0
@export var attack_trigger_distance: float = 2.0
@export var attack_step_distance: float = 0.8

var state: State
var target: Node3D
var target_position: Vector3


func _ready() -> void:
    target = get_viewport().get_camera_3d()
    if target: target = target.get_parent()
    animator.animation_finished.connect(_on_animation_finished)
    step_animator.step_taken.connect(move_with_step)
    step_animator.animator = animator
    ragdoll.active = false
    step_animator.take_step()

func _process(_delta: float) -> void:
    if target:
        target_position = target.global_position
        target_position -= target.global_basis.z * target_lead_distance

    if Input.is_key_pressed(KEY_1) && !ragdoll.active:
        ragdoll.active = true
        ragdoll.physical_bones_start_simulation()
        force_node.apply_central_impulse(Vector3.FORWARD * 100)
    if Input.is_key_pressed(KEY_2) && ragdoll.active:
        ragdoll.active = false
        ragdoll.physical_bones_stop_simulation()


    match state:
        TRACKING:
            if target_position.distance_to(global_position) < attack_trigger_distance:
                attack()
        ATTACKING: pass

func _physics_process(_delta: float) -> void:
    velocity += get_gravity()
    move_and_slide()


func attack():
    state = ATTACKING
    step_animator.stop_step()
    animator.play("attack")
    animator.advance(0)
    move_with_step(attack_step_distance)


func move_with_step(distance: float):
    var target_offset = target_position - global_position
    target_offset.y = 0
    var look_target = global_position + target_offset
    look_at(look_target, Vector3.UP, true)
    velocity = basis.z * distance * Engine.physics_ticks_per_second
    move_and_slide()
    velocity *= Vector3.UP

func _on_animation_finished(_animation_name: String):
    if state == ATTACKING:
        state = TRACKING
        step_animator.take_step()
