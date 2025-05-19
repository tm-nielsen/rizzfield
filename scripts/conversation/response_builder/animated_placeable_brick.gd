extends PlaceableBrick

@export var update_timer: FrameTimer

@export_subgroup("rotation", "rotation")
@export var rotation_planar_sensitivity: float = 1.0
@export_subgroup("rotation/elastic", "elastic_rotation")
@export var elastic_rotation_planar: ElasticVector2
@export var elastic_rotation_normal: ElasticValue

@export_subgroup("momentum", "momentum")
@export_range(0, 1) var momentum_inherit: float = 0.5
@export var momentum_maximum: float = 10

var displacement: Vector3

func _ready() -> void:
    super()
    elastic_rotation_planar = elastic_rotation_planar.duplicate()
    elastic_rotation_normal = elastic_rotation_normal.duplicate()
    elastic_rotation_normal.value = target_rotation.y
    update_timer.frame_out.connect(apply_elastic_values)

func _physics_process(delta: float) -> void:
    if held:
        var last_position := position
        super(delta)
        displacement = position - last_position
        displacement *= momentum_inherit
        update_elastic_values(delta)
        displacement /= delta


func drop():
    super()
    apply_momentum()


func update_elastic_values(delta: float):
    var delta_scale = delta * ElasticValue.SCALING_FRAMERATE

    var target_planar_rotation = Vector2(
        -displacement.z, displacement.x
    ).rotated(
        target_rotation.y
    ) * rotation_planar_sensitivity
    target_planar_rotation += Vector2(
        target_rotation.x, target_rotation.z
    )
    elastic_rotation_planar.update_value(
        target_planar_rotation, delta_scale
    )

    elastic_rotation_normal.update_value(
        target_rotation.y, delta_scale, PI
    )

func apply_elastic_values():
    if held:
        rotation = Vector3(
            elastic_rotation_planar.x,
            elastic_rotation_normal.value,
            elastic_rotation_planar.y
        )

func apply_momentum():
    var momentum = displacement
    displacement.clampf(
        -momentum_maximum, momentum_maximum
    )
    linear_velocity = momentum