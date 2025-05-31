extends ColorRect

func _ready():
    hide()
    GameModeSignalBus.game_ended.connect(
        func():
        show()
        get_tree().quit.call_deferred()
    )
