class_name ElasticValue
extends Resource

@export var elasticity: float = 0.05
@export_range(0, 1) var friction: float = 0.2

var value_velocity: float
var value: float

func update_value(target: float, delta_scale: float, wrap_limit = 0) -> float:
    var offset = get_wrapped_target_offset(target, value, wrap_limit)
    value_velocity += offset * elasticity * delta_scale
    value += wrap_value(value + value_velocity, wrap_limit)
    value_velocity = apply_friction(value_velocity, friction, delta_scale)
    return value


static func apply_friction(a: float, f: float, delta_scale: float) -> float:
    return a * max(1 - f * delta_scale, 0)


static func wrap_value(v: float, wrap_limit: float) -> float:
    if wrap_limit == 0: return v
    while v > wrap_limit: v -= wrap_limit * 2
    while v < -wrap_limit: v += wrap_limit * 2
    return v


static func get_wrapped_target_offset(target: float, v: float, wrap_limit: float) -> float:
    var minimum_offset = target - v
    if wrap_limit == 0: return minimum_offset

    var wrapped_target = target + wrap_limit * 2
    var wrapped_offset = wrapped_target - v
    if abs(wrapped_offset) < abs(minimum_offset):
        minimum_offset = wrapped_offset

    wrapped_target = target - wrap_limit * 2
    wrapped_offset = wrapped_target - v
    if abs(wrapped_offset) < abs(minimum_offset):
        minimum_offset = wrapped_offset
    return minimum_offset
