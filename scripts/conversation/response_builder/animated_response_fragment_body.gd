extends ResponseFragmentBody

@export var placement_tween_duration: float = 0.5
@export var update_timer: FrameTimer

@export_subgroup("rotation", "rotation")
@export var rotation_planar_sensitivity: float = 2
@export_subgroup("rotation/elastic", "elastic_rotation")
@export var elastic_rotation_planar: ElasticVector2
@export var elastic_rotation_normal: ElasticValue

@export_subgroup("momentum", "momentum")
@export_range(0, 1) var momentum_inherit: float = 0.5
@export var momentum_maximum: float = 10

var displacement: Vector3
var placement_tween: Tween


func _ready() -> void:
    super()
    elastic_rotation_planar = elastic_rotation_planar.duplicate()
    elastic_rotation_normal = elastic_rotation_normal.duplicate()
    update_timer.frame_out.connect(apply_elastic_values)
    update_timer.frame_out.connect(update_placement_tween)
    dropped.connect(apply_momentum)
    grabbed.connect(end_placement_tween)

func _physics_process(delta: float) -> void:
    if state != HELD: return
    var last_position := position
    super(delta)
    displacement = position - last_position
    displacement *= momentum_inherit
    update_elastic_values(delta)
    displacement /= delta


func update_elastic_values(delta: float):
    var delta_scale = delta * ElasticValue.SCALING_FRAMERATE

    var target_planar_rotation = Vector2(
        -displacement.z, displacement.x
    ).rotated(
        placement_rotation.y
    ) * rotation_planar_sensitivity
    target_planar_rotation += Vector2(
        placement_rotation.x, placement_rotation.z
    )
    elastic_rotation_planar.update_value(
        target_planar_rotation, delta_scale
    )

    elastic_rotation_normal.update_value(
        placement_rotation.y, delta_scale, PI
    )


func apply_elastic_values():
    if state == HELD:
        rotation = Vector3(
            elastic_rotation_planar.x,
            elastic_rotation_normal.value,
            elastic_rotation_planar.y
        )


func place(point: Vector3):
    placement_tween = create_tween()
    placement_tween.set_ease(Tween.EASE_OUT)
    placement_tween.set_trans(Tween.TRANS_ELASTIC)
    placement_tween.set_parallel()
    placement_tween.tween_property(
        self, 'global_position', point,
        placement_tween_duration
    )
    placement_tween.tween_property(
        self, 'quaternion',
        Quaternion.from_euler(
            placement_rotation
        ),
        placement_tween_duration
    )
    placement_tween.tween_callback(
        func():
            global_position = point
            rotation = placement_rotation
    )
    placement_tween.pause()
    update_placement_tween()

func update_placement_tween():
    if placement_tween:
        if !placement_tween.custom_step(
            update_timer.frame_period
        ): placement_tween = null

func end_placement_tween():
    if placement_tween:
        placement_tween.kill()
        placement_tween = null


func apply_momentum():
    var momentum = displacement
    displacement.clampf(
        -momentum_maximum, momentum_maximum
    )
    linear_velocity = momentum
