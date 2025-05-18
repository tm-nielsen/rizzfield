extends Node

@export var target: Node

func _ready() -> void:
    GameModeSignalBus.conversation_started.connect(
        func(): target.process_mode = Node.PROCESS_MODE_DISABLED
    )
    GameModeSignalBus.conversation_ended.connect(
        func(): target.process_mode = Node.PROCESS_MODE_INHERIT
    )
