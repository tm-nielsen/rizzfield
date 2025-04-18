extends MeshInstance3D

@export var curve: Curve
@export var base_duration: float = 1/3.0
@export var frame_timer: FrameTimer

@onready var material: ShaderMaterial = get_surface_override_material(0)
var linear_influence: float


func _ready() -> void:
    set_influence(0)
    frame_timer.frame_out.connect(update_influence)

func update_influence():
    set_influence(curve.sample(linear_influence))


func set_influence(influence: float):
    material.set_shader_parameter("influence", influence)

func set_angle(angle: float):
    material.set_shader_parameter("angle", angle)


func _on_player_damaged(amount: int, impulse: Vector3):
    var x_diff = global_basis.x.dot(impulse)
    var z_diff = global_basis.z.dot(impulse)
    set_angle(atan2(-z_diff, x_diff))

    linear_influence = 1
    update_influence()

    var influence_tween = create_tween()
    influence_tween.tween_property(
        self, "linear_influence", 0.0, base_duration * amount
    )
