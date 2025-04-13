class_name ElasticVector2
extends Resource

@export var elasticity := Vector2(10.0, 10.0)
@export var damping := Vector2(0.1, 0.1)

var value_velocity: Vector2
var value: Vector2

var x: get = _get_x
var y: get = _get_y


func update_value(target: Vector2, delta: float, wrap_limit: float = 0) -> Vector2:
    var x_offset = ElasticValue.get_wrapped_target_offset(target.x, x, wrap_limit)
    var y_offset = ElasticValue.get_wrapped_target_offset(target.y, y, wrap_limit)
    value_velocity += Vector2(x_offset, y_offset) * elasticity * delta
    value_velocity *= Vector2.ONE - damping
    value += value_velocity
    wrap_value(wrap_limit)
    return value


func wrap_value(wrap_limit: float):
    if wrap_limit == 0: return
    value.x = ElasticValue.wrap_value(x, wrap_limit)
    value.y = ElasticValue.wrap_value(y, wrap_limit)


static func damp(a: Vector2, lambda: float, delta: float):
    a.x = ElasticValue.damp(a.x, lambda, delta)
    a.y = ElasticValue.damp(a.y, lambda, delta)


func _get_x() -> float: return value.x
func _get_y() -> float: return value.y