extends Node3D

enum State {
    TRACKING, ATTACKING
}
const TRACKING = State.TRACKING
const ATTACKING = State.ATTACKING

@export var animator: AnimationPlayer
@export var step_animator: ProceduralStepAnimator

@export_subgroup("behaviour parameters")
@export var target_lead_distance: float = 3.0
@export var attack_distance: float = 2.0

var state: State
var target: Node3D
var target_position: Vector3


func _ready() -> void:
    target = get_viewport().get_camera_3d().get_parent()
    animator.animation_finished.connect(_on_animation_finished)
    step_animator.step_taken.connect(_on_step_taken)
    step_animator.animator = animator
    step_animator.take_step()

func _process(_delta: float) -> void:
    target_position = target.global_position
    target_position -= target.global_basis.z * target_lead_distance

    match state:
        TRACKING:
            if target_position.distance_to(global_position) < attack_distance:
                attack()
        ATTACKING: pass


func attack():
    state = ATTACKING
    step_animator.stop_step()
    animator.play("attack")


func _on_step_taken(distance: float):
    transform = transform.looking_at(target_position, Vector3.UP, true)
    position += transform.basis.z * distance

func _on_animation_finished(_animation_name: String):
    if state == ATTACKING:
        state = TRACKING
        step_animator.take_step()
