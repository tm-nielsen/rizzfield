extends Area3D

signal damage_sent(damage: int)

@export var damage: int = 1
@export var impact_direction := Vector3.FORWARD
@export var impact_scale: float = 1

func _ready():
    body_entered.connect(_on_body_entered)


func _on_body_entered(body):
    if body.has_method("receive_damage"):
        var impact = global_basis * impact_direction
        body.receive_damage(damage, impact * impact_scale)
        damage_sent.emit(damage)
