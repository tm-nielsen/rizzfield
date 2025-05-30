extends DamageableCharacterBody3D

const TRACKING = 4
const ATTACKING = 5
const RETREATING = 6

@export_subgroup("flinch")
@export var flinch_bone_angle_range: float = 0.5
@export var parry_flinch_duration: float = 1.0
@export var parry_flinch_recoil_distance: float = 0.4

@export_subgroup("references")
@export var animator: AnimationPlayer
@export var collider: CollisionShape3D
@export var hurtbox: Area3D
@export var step_animator: ProceduralStepAnimator
@export var ragdoll: PhysicalBoneSimulator3D
@export var force_node: PhysicalBone3D
@export var eyes_parent: Node3D
@export var smile: Node3D

@export_subgroup("behaviour parameters")
@export var target_lead_distance: float = 0
@export var attack_trigger_distance: float = 3.0
@export var attack_distance: float = 1.5

var target: Node3D
var target_position: Vector3

var is_target_in_range: bool: get = _get_is_target_in_range


func _ready() -> void:
    if state == DEAD: return
    target = get_viewport().get_camera_3d()
    if target: target = target.get_parent()
    update_target_position()
    animator.animation_finished.connect(_on_animation_finished)
    step_animator.step_taken.connect(move_with_step)
    ragdoll.active = false
    smile.hide()
    state = IDLE
    step_animator.animator = animator
    animator.play("step")

func _process(_delta: float) -> void:
    if target && state != DEAD:
        update_target_position()
        if state == TRACKING && is_target_in_range: attack()

func _physics_process(_delta: float) -> void:
    if state == DEAD: return
    velocity += get_gravity()
    move_and_slide()


func start_tracking():
    state = TRACKING
    look_at_target()
    step_animator.take_step()

func start_retreat(base_steps: int = 2, variance: int = 2):
    state = RETREATING
    look_at_target()
    var step_count = base_steps + (
        0 if variance < 1 else randi() % variance
    )
    step_animator.take_steps_back(step_count, _on_retreat_completed)


func update_target_position():
    if !target: return
    target_position = target.global_position
    target_position -= target.global_basis.z * target_lead_distance


func attack():
    state = ATTACKING
    step_animator.stop_step()
    animator.play("attack")
    animator.advance(0)
    step_animator.flip_base()

    var target_offset = global_position - target_position
    var attack_offset = target_offset.normalized() * attack_distance
    var attack_position = target_position + attack_offset
    move_units(attack_position - global_position)


func move_with_step(distance: Vector2):
    var displacement = Vector3.ZERO
    displacement += basis.z * distance.y
    displacement += basis.x * distance.x
    move_units(displacement)

func move_units(displacement: Vector3):
    if !can_process(): return
    velocity = displacement * Engine.physics_ticks_per_second
    move_and_slide()
    look_at_target()
    velocity *= Vector3.UP

func look_at_target():
    var target_offset = target_position - global_position
    target_offset.y = 0
    var look_target = global_position + target_offset
    look_at(look_target, Vector3.UP, true)


func receive_damage(amount: int, impact: Vector3):
    super(amount, impact)
    if health > 0:
        var angle_range = flinch_bone_angle_range * amount
        step_animator.randomize_pose(angle_range)


func start_flinch():
    if state == STUNNED: state = RETREATING
    super()
    step_animator.stop_step()
    animator.pause()

func end_flinch(previous_state: int):
    super(previous_state)
    if state == STUNNED || state == DAMAGED: state = TRACKING
    if state == TRACKING: step_animator.take_step()
    if state == STUNNED || state == RETREATING:
        look_at_target()
        step_animator.take_steps_back(5, _on_retreat_completed)
    if state != DEAD: animator.play()


func start_parry_flinch():
    state = STUNNED
    step_animator.reset_base()
    animator.play("step")
    animator.advance(1)
    step_animator.randomize_pose(flinch_bone_angle_range)
    move_with_step(Vector2.UP * parry_flinch_recoil_distance)
    _end_flinch_in(parry_flinch_duration, RETREATING)


func die(force: Vector3):
    super(force)
    state = DEAD
    step_animator.stop_step()
    collider.disabled = true
    hurtbox.monitoring = false
    eyes_parent.hide()
    ragdoll.active = true
    ragdoll.physical_bones_start_simulation()
    if !can_process(): return
    force_node.apply_central_impulse(force * Engine.physics_ticks_per_second)


func _on_animation_finished(_animation_name: String):
    if state == ATTACKING: start_retreat()

func _on_retreat_completed():
    state = IDLE
    TweenHelpers.call_delayed(start_tracking, randf())


func _get_is_target_in_range() -> bool:
    var target_distance = target_position.distance_to(global_position)
    return target_distance < attack_trigger_distance
