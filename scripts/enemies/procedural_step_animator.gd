class_name ProceduralStepAnimator
extends Skeleton3D

signal step_taken(distance: Vector2)
const FRAME_TIME = 1.0 / 12.0

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
    _start_step()
    _finish_step(randf_range(min_step_delay, max_step_delay))

func take_steps_back(step_count: int, callback: Callable):
    if step_count <= 0:
        callback.call()
    else:
        _start_step(true)
        var next = take_steps_back.bind(step_count - 1, callback)
        _finish_step(0, next)

func stop_step():
    if step_tween: step_tween.kill()


func _start_step(move_backwards := false):
    stop_step()
    set_base_position()
    apply_default_step_pose()
    generate_step_pose()
    apply_overshot_step_pose()
    move_with_step(move_backwards)

func _finish_step(next_step_delay: float, next_step_method: Callable = take_step):
    step_tween = create_tween()
    step_tween.tween_interval(FRAME_TIME)
    step_tween.tween_callback(apply_step_pose)
    step_tween.tween_interval(FRAME_TIME)
    step_tween.tween_interval(next_step_delay)
    step_tween.tween_callback(next_step_method)


func move_with_step(move_backwards := false):
    var x_distance = randf_range(min_step_distance.x, max_step_distance.x)
    x_distance *= step_direction
    var y_distance = randf_range(min_step_distance.y, max_step_distance.y)
    if move_backwards: y_distance *= -1
    step_taken.emit(Vector2(x_distance, y_distance))


func set_base_position():
    step_direction *= -1
    var base_position := get_bone_rest(0).origin
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

        var random_rotation := rand_quaternion()
        step_rotations[i] = base_rotation * random_rotation
    )

func apply_overshot_step_pose():
    iterate_bones(func (i: int):
        var last := last_step_rotations[i] if last_step_rotations.has(i) else get_bone_pose_rotation(i)
        last = last.normalized()
        var next := step_rotations[i].normalized()
        var overshot_rotation = last.slerp(next, overshoot_factor)
        set_bone_pose_rotation(i, overshot_rotation)
    )

func apply_step_pose():
    iterate_bones(func (i):
        set_bone_pose_rotation(i, step_rotations[i])
    )


func randomize_pose(angle_range: float):
    iterate_bones(func(i: int):
        var base_rotation = get_bone_pose_rotation(i)
        var random_rotation = rand_quaternion(angle_range)
        var offset_rotation = base_rotation * random_rotation
        set_bone_pose_rotation(i, offset_rotation)
    )


func iterate_bones(method: Callable, root_index: int = 0):
    for bone_index in get_bone_children(root_index):
        var bone_name := get_bone_name(bone_index)
        if ["Right Foot", "Left Hip"].has(bone_name): continue
        if !["Right Shin", "Right Thigh", "Right Hip"].has(bone_name):
            method.call(bone_index)
        iterate_bones(method, bone_index)


func rand_quaternion(angle: float = random_angle_range) -> Quaternion:
    return Quaternion.from_euler(
        Vector3(rand_angle(angle), rand_angle(angle), rand_angle(angle))
    )

func rand_angle(a: float = random_angle_range) -> float:
    return randf_range(-a, a)
