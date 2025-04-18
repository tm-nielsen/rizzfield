extends Area3D

signal damage_sent(damage: int)

@export var damage: int = 1
@export var impact_direction := Vector3.FORWARD
@export var impact_scale: float = 1

func _ready():
    body_entered.connect(_on_body_entered)
    monitoring = false


func _on_body_entered(body):
    if _is_parent(body, self): return
    if body.has_method("receive_damage"):
        var impact = global_basis * impact_direction
        body.receive_damage(damage, impact * impact_scale)
        damage_sent.emit(damage)

func _is_parent(node: Node, child: Node) -> bool:
    if !child: return false
    if child == node: return true
    return _is_parent(node, child.get_parent());
