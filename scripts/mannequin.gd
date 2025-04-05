extends Skeleton3D

@export var angle: float = PI/12
@export var min_step_delay: float = 0.05
@export var max_step_delay: float = 0.15

@export var min_step_distance := Vector2(0.1, 0.5)
@export var max_step_distance := Vector2(0.3, 1)

var step_direction: int = 1


func _ready() -> void:
    take_step()


func take_step():
    move_with_step()
    set_base_position()
    randomize_pose()
    var tween = create_tween()
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


func randomize_pose():

    for i in range(1, get_bone_count()):
        if get_bone_name(i) == "Right Foot": continue
        
        var q := get_bone_rest(i).basis.get_rotation_quaternion()
        var rot = Quaternion.from_euler(
            Vector3(rand_angle(), rand_angle(), rand_angle())
        )
        set_bone_pose_rotation(i, q * rot)


func rand_angle(a: float = angle) -> float:
    return randf_range(-a, a)