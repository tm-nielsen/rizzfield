class_name ExitArea
extends Area3D

static var encounters_completed: int

@export var encounter_count: int = 4


func _ready():
    GameModeSignalBus.player_died.connect(reset_count)
    hide()

func _process(_delta: float) -> void:
    if !visible && encounters_completed >= encounter_count:
        show()
        body_entered.connect(
            func(body):
            if !body is PlayerController: return
            GameModeSignalBus.notify_game_ended()
        )


static func notify_encounter_completed():
    encounters_completed += 1

static func reset_count():
    encounters_completed = 0
