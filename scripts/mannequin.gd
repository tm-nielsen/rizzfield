extends Skeleton3D

@export var angle: float = PI/12
@export var randomize_delay: float = 1
@export var step_offset: float = 0.2

var step_direction: int = 1


func _ready() -> void:
    var tween = create_tween();
    tween.set_loops()
    tween.tween_callback(randomize_pose)
    tween.tween_interval(randomize_delay)


func randomize_pose():
    step_direction *= -1
    var base_position := get_bone_rest(0).origin
    base_position.x += step_direction * step_offset
    var base_scale = Vector3(-step_direction, 1, 1)

    var base_t = Transform3D(
        Basis.from_scale(base_scale), base_position
    )
    set_bone_pose(0, base_t)

    for i in range(1, get_bone_count()):
        if get_bone_name(i) == "Right Foot": continue
        
        var q := get_bone_rest(i).basis.get_rotation_quaternion()
        var rot = Quaternion.from_euler(
            Vector3(rand_angle(), rand_angle(), rand_angle())
        )
        set_bone_pose_rotation(i, q * rot)


func rand_angle(a: float = angle) -> float:
    return randf_range(-a, a)