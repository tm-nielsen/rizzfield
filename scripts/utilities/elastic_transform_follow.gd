extends Node3D

@export var target: Node3D

@export var elastic_position: ElasticVector2
@export var elastic_rotation: ElasticVector2


func _process(delta: float) -> void:
    var frame_rate = Engine.max_fps
    if frame_rate == 0:
        frame_rate = DisplayServer.screen_get_refresh_rate()
    var delta_scale = delta * frame_rate

    var target_position = Vector2(target.position.x, target.position.y)
    elastic_position.update_value(target_position, delta_scale)
    position.x = elastic_position.x
    position.y = elastic_position.y

    var source_rotation = target.global_rotation
    var target_rotation = Vector2(source_rotation.y, source_rotation.x)
    elastic_rotation.update_value(target_rotation, delta_scale, PI)
    global_rotation.y = elastic_rotation.x
    rotation.x = elastic_rotation.y