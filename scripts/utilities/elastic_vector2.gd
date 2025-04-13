class_name ElasticVector2
extends Resource

@export var elasticity := Vector2(0.05, 0.05)
@export var friction := Vector2(0.2, 0.2)

var value_velocity: Vector2
var value: Vector2

var x: get = _get_x
var y: get = _get_y


func update_value(target: Vector2, delta_scale: float, wrap_limit: float = 0) -> Vector2:
    var x_offset = ElasticValue.get_wrapped_target_offset(target.x, x, wrap_limit)
    var y_offset = ElasticValue.get_wrapped_target_offset(target.y, y, wrap_limit)
    value_velocity += Vector2(x_offset, y_offset) * elasticity * delta_scale
    value += value_velocity
    value_velocity = apply_friction(value_velocity, friction, delta_scale)
    wrap_value(wrap_limit)
    return value


func wrap_value(wrap_limit: float):
    if wrap_limit == 0: return
    value.x = ElasticValue.wrap_value(x, wrap_limit)
    value.y = ElasticValue.wrap_value(y, wrap_limit)


static func apply_friction(a: Vector2, f: Vector2, delta_scale: float) -> Vector2:
    a.x = ElasticValue.apply_friction(a.x, f.x, delta_scale)
    a.y = ElasticValue.apply_friction(a.y, f.y, delta_scale)
    return a


func _get_x() -> float: return value.x
func _get_y() -> float: return value.y