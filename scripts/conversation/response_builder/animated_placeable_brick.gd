extends PlaceableBrick

@export var update_timer: FrameTimer

@export_subgroup("threaten", "threaten")
@export var threaten_depth_offset = 1
@export var threaten_blink_colour := Color.WEB_MAROON
@export_subgroup("threaten/shake", "threaten_shake")
@export var threaten_shake_frequency := Vector3(5, 6, 7)
@export var threaten_shake_amplitude := Vector3(0.1, 0.1, 0.2)

@export_subgroup("rotation", "rotation")
@export var rotation_planar_sensitivity: float = 1.0
@export_subgroup("rotation/elastic", "elastic_rotation")
@export var elastic_rotation_planar: ElasticVector2
@export var elastic_rotation_normal: ElasticValue

@export_subgroup("momentum", "momentum")
@export_range(0, 1) var momentum_inherit: float = 0.5
@export var momentum_maximum: float = 10

var threaten_blink_on: bool
var threaten_offset: Vector3

var displacement: Vector3


func _ready() -> void:
    super()
    elastic_rotation_planar = elastic_rotation_planar.duplicate()
    elastic_rotation_normal = elastic_rotation_normal.duplicate()
    update_timer.frame_out.connect(apply_elastic_values)
    update_timer.frame_out.connect(update_threaten_animation)

func _physics_process(delta: float) -> void:
    if held:
        var last_position := position
        super(delta)
        if can_place: apply_threaten_animation()
        else: set_colour(colour_grabbed)
        displacement = position - last_position
        displacement *= momentum_inherit
        update_elastic_values(delta)
        displacement /= delta


func update_threaten_animation():
    if held && can_place:
        threaten_blink_on = !threaten_blink_on
        var time = Time.get_ticks_msec() / 1000.0
        threaten_offset = Vector3(
            sin(threaten_shake_frequency.x * TAU * time),
            sin(threaten_shake_frequency.y * TAU * time),
            sin(threaten_shake_frequency.z * TAU * time),
        ) * threaten_shake_amplitude

func apply_threaten_animation():
    position += threaten_offset
    position.y += threaten_depth_offset
    set_colour(
        threaten_blink_colour
        if threaten_blink_on else colour_grabbed
    )


func drop():
    super()
    apply_momentum()

func reset():
    super()
    elastic_rotation_normal.value = target_rotation.y


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