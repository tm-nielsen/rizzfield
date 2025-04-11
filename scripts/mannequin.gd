extends Skeleton3D

@export var angle: float = PI/12
@export var overshoot_factor: float = 1.1
@export var min_step_delay: float = 0.05
@export var max_step_delay: float = 0.15

@export var min_step_distance := Vector2(0.1, 0.5)
@export var max_step_distance := Vector2(0.3, 1)

@export var animator: AnimationPlayer

var step_direction: int = 1

var last_step_rotations: Dictionary[int, Quaternion]
var step_rotations: Dictionary[int, Quaternion]


func _ready() -> void:
    take_step()


func take_step():
    move_with_step()
    set_base_position()
    apply_default_step_pose()
    generate_step_pose()
    apply_overshot_step_pose()
    var tween = create_tween()
    tween.tween_interval(1 / 12.0)
    tween.tween_callback(apply_step_pose)
    tween.tween_interval(randf_range(min_step_delay, max_step_delay))
    tween.tween_callback(take_step)


func move_with_step():
    position.z += randf_range(min_step_distance.y, max_step_distance.y)
    if position.z > 0:
        position.z -= 10


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
    for i in range(1, get_bone_count()):
        if get_bone_name(i) == "Right Foot": continue
        method.call(i)


func rand_angle(a: float = angle) -> float:
    return randf_range(-a, a)
