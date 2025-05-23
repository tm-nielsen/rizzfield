extends Node

signal game_started
signal player_died

signal conversation_triggered(
    definition: ConversationDefinition,
    vignette_scene: Node3D
)
signal conversation_resolved()
signal combat_triggered()
signal brick_thrown()

signal conversation_started
signal conversation_ended


func notify_game_started():
    game_started.emit()

func notify_player_died():
    player_died.emit()


func notify_conversation_triggered(
    definition: ConversationDefinition,
    vignette_scene: Node3D
):
    conversation_triggered.emit(definition, vignette_scene)
    conversation_started.emit()

func notify_conversation_resolved():
    conversation_resolved.emit()
    conversation_ended.emit()

func notify_combat_triggered():
    combat_triggered.emit()
    conversation_ended.emit()

func notify_brick_thrown():
    brick_thrown.emit()
    conversation_ended.emit()
