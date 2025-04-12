class_name ProceduralStepAnimator
extends Skeleton3D

signal step_taken(distance: float)

@export var animator: AnimationPlayer

@export_subgroup("step parameters")
@export var random_angle_range: float = 0.4
@export var overshoot_factor: float = 1.2
@export var min_step_delay: float = 0.0
@export var max_step_delay: float = 0.3

@export var min_step_distance := Vector2(-0.1, 0.6)
@export var max_step_distance := Vector2(0.5, 1.4)

var step_direction: int = 1
var step_tween: Tween

var last_step_rotations: Dictionary[int, Quaternion]
var step_rotations: Dictionary[int, Quaternion]


func take_step():
    if step_tween: step_tween.kill()
    set_base_position()
    apply_default_step_pose()
    generate_step_pose()
    apply_overshot_step_pose()
    move_with_step()
    step_tween = create_tween()
    step_tween.tween_interval(1 / 12.0)
    step_tween.tween_callback(apply_step_pose)
    step_tween.tween_interval(randf_range(min_step_delay, max_step_delay))
    step_tween.tween_callback(take_step)

func stop_step():
    step_tween.kill()


func move_with_step():
    var distance = randf_range(min_step_distance.y, max_step_distance.y)
    step_taken.emit(distance)


func set_base_position():
    step_direction *= -1
    var base_position := get_bone_rest(0).origin
    base_position.x += step_direction * randf_range(min_step_distance.x, max_step_distance.x)
    var base_scale = Vector3(-step_direction, 1, 1)

    var base_t = Transform3D(
        Basis.from_scale(base_scale), base_position
    )
    set_bone_pose(0, base_t)


func apply_default_step_pose():
    animator.play("step")
    animator.advance(0)


func generate_step_pose():
    last_step_rotations = step_rotations.duplicate()
    iterate_bones(func (i: int):
        var base_rotation := get_bone_pose_rotation(i)

        var random_rotation := Quaternion.from_euler(
            Vector3(rand_angle(), rand_angle(), rand_angle())
        )
        step_rotations[i] = base_rotation * random_rotation
    )

func apply_overshot_step_pose():
    iterate_bones(func (i: int):
        var last := last_step_rotations[i] if last_step_rotations.has(i) else get_bone_pose_rotation(i)
        var next := step_rotations[i]
        var overshot_rotation = last.slerp(next, overshoot_factor)
        set_bone_pose_rotation(i, overshot_rotation)
    )

func apply_step_pose():
    iterate_bones(func (i):
        set_bone_pose_rotation(i, step_rotations[i])
    )


func iterate_bones(method: Callable, root_index: int = 0):
    for bone_index in get_bone_children(root_index):
        var bone_name := get_bone_name(bone_index)
        if ["Right Foot", "Left Hip"].has(bone_name): continue
        if !["Right Shin", "Right Thigh", "Right Hip"].has(bone_name):
            method.call(bone_index)
        iterate_bones(method, bone_index)


func rand_angle(a: float = random_angle_range) -> float:
    return randf_range(-a, a)
