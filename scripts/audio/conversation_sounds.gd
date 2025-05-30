extends AudioClipPlayer

@export var conversation_manager: ConversationManager
@export var started: AudioStream
@export var resolved: AudioStream
@export var failed: AudioStream

@export_subgroup("response sounds", "responded")
@export var responded_negative: AudioStream
@export var responded_neutral: AudioStream
@export var responded_positive: AudioStream


func _ready() -> void:
    connect_clip(GameModeSignalBus.conversation_started, started)
    connect_clip(conversation_manager.resolved, resolved)
    connect_clip(conversation_manager.failed, failed)
    conversation_manager.response_submitted.connect(
        play_tiered_response_clip
    )

func play_tiered_response_clip(success_level: ResponseValues.SuccessLevel):
    match success_level:
        ResponseValues.NEGATIVE: play_clip(responded_negative)
        ResponseValues.NEUTRAL: play_clip(responded_neutral)
        ResponseValues.POSITIVE: play_clip(responded_positive)
