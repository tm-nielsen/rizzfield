extends Node

signal conversation_triggered(vignette_scene: Node3D)
signal conversation_resolved()
signal combat_triggered()


func notify_conversation_triggered(vignette_scene: Node3D):
    conversation_triggered.emit(vignette_scene)

func notify_conversation_resolved():
    conversation_resolved.emit()

func notify_combat_triggered():
    combat_triggered.emit()