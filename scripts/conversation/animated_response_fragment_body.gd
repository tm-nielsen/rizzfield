extends ResponseFragmentBody

@export_range(0, 1) var momentum_inherit: float = 0.5
@export var maximum_momentum: float = 10

var displacement: Vector3


func _ready() -> void:
    super()
    dropped.connect(apply_momentum)

func _physics_process(delta: float) -> void:
    var last_position := position
    super(delta)
    displacement = position - last_position
    displacement *= momentum_inherit
    displacement /= delta

func apply_momentum():
    var momentum = displacement
    displacement.clampf(
        -maximum_momentum, maximum_momentum
    )
    linear_velocity = momentum
