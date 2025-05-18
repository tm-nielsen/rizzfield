extends Node

signal conversation_triggered(
    definition: ConversationDefinition,
    vignette_scene: Node3D
)
signal conversation_resolved()
signal combat_triggered()

signal conversation_started
signal conversation_ended


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