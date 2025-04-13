class_name ElasticValue
extends Resource

@export var elasticity: float = 10.0
@export_range(0, 1) var damping: float = 0.1

var value_velocity: float
var value: float

func update_value(target: float, delta: float, wrap_limit = 0) -> float:
    value_velocity += get_wrapped_target_offset(target, value, wrap_limit) * elasticity
    value_velocity *= damp(value_velocity, damping, delta)
    value += wrap_value(value + value_velocity, wrap_limit)
    return value


static func damp(a: float, lambda: float, delta: float):
    return lerp(a, 0, 1 - exp(-lambda * delta))


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