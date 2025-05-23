extends Node

@export var target: Node

func _ready() -> void:
    pause_world()
    GameModeSignalBus.game_started.connect(unpause_world)
    GameModeSignalBus.player_died.connect(pause_world)
    GameModeSignalBus.conversation_started.connect(pause_world)
    GameModeSignalBus.conversation_ended.connect(unpause_world)

func pause_world():
    target.process_mode = Node.PROCESS_MODE_DISABLED

func unpause_world():
    target.process_mode = Node.PROCESS_MODE_INHERIT
