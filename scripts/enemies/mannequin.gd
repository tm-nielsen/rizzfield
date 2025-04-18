extends DamageableCharacterBody3D

@export_subgroup("flinch")
@export var flinch_bone_angle_range: float = 0.5

@export_subgroup("references")
@export var animator: AnimationPlayer
@export var step_animator: ProceduralStepAnimator
@export var ragdoll: PhysicalBoneSimulator3D
@export var force_node: PhysicalBone3D

@export_subgroup("behaviour parameters")
@export var target_lead_distance: float = 0
@export var attack_trigger_distance: float = 3.0
@export var attack_step_distance: float = 0.8

var target: Node3D
var target_position: Vector3

var is_target_in_range: bool: get = _get_is_target_in_range


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

    if Input.is_key_pressed(KEY_2) && ragdoll.active:
        ragdoll.active = false
        ragdoll.physical_bones_stop_simulation()
        collision_layer = 12
        health = maximum_health
        state = TRACKING
        step_animator.take_step()

    if state == TRACKING && is_target_in_range: attack()

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
    velocity = basis.z * distance * Engine.physics_ticks_per_second
    move_and_slide()
    look_at_target()
    velocity *= Vector3.UP

func look_at_target():
    var target_offset = target_position - global_position
    target_offset.y = 0
    var look_target = global_position + target_offset
    look_at(look_target, Vector3.UP, true)


func receive_damage(damage: int, force: Vector3):
    super(damage, force)
    if health > 0:
        var angle_range = flinch_bone_angle_range * damage
        step_animator.randomize_pose(angle_range)


func start_flinch():
    super()
    state = DAMAGED
    step_animator.stop_step()
    animator.pause()

func end_flinch(previous_state: State):
    super(previous_state)
    if state == TRACKING: step_animator.take_step()
    animator.play()


func die(force: Vector3):
    state = DEAD
    collision_layer = 0
    ragdoll.active = true
    ragdoll.physical_bones_start_simulation()
    force_node.apply_central_impulse(force * Engine.physics_ticks_per_second)


func _on_animation_finished(_animation_name: String):
    if state == ATTACKING:
        if is_target_in_range:
            step_animator.set_base_position()
            attack()
        else:
            state = TRACKING
            step_animator.take_step()


func _get_is_target_in_range() -> bool:
    var target_distance = target_position.distance_to(global_position)
    return target_distance < attack_trigger_distance
