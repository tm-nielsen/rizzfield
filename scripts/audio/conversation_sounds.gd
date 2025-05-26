extends AudioClipPlayer

@export var conversation_manager: ConversationManager
@export var started: AudioStream
@export var resolved: AudioStream
@export var failed: AudioStream
@export var responded: AudioStream

func _ready() -> void:
    connect_clip(GameModeSignalBus.conversation_started, started)
    connect_clip(conversation_manager.resolved, resolved)
    connect_clip(conversation_manager.failed, failed)
    connect_clip(conversation_manager.response_submitted, responded)