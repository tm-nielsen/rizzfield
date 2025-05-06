extends ResponseFragmentBody

@export_subgroup("rotation", "rotation")
@export var rotation_planar_sensitivity: float = 2
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
    dropped.connect(apply_momentum)

func _physics_process(delta: float) -> void:
    if state == PLACED: return
    var last_position := position
    super(delta)
    displacement = position - last_position
    displacement *= momentum_inherit
    update_elastic_values(delta)
    displacement /= delta
    apply_elastic_values()


func update_elastic_values(delta: float):
    var delta_scale = delta * ElasticValue.SCALING_FRAMERATE
    var base_rotation = get_placement_rotation()

    var target_planar_rotation = Vector2(
        -displacement.z, displacement.x
    ).rotated(
        base_rotation.y
    ) * rotation_planar_sensitivity
    target_planar_rotation += Vector2(
        base_rotation.x, base_rotation.z
    )
    elastic_rotation_planar.update_value(
        target_planar_rotation, delta_scale
    )

    elastic_rotation_normal.update_value(
        base_rotation.y, delta_scale, PI
    )


func apply_elastic_values():
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
