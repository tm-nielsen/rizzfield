extends Control

@export var view: ConversationView
@export var vignette_viewport: SubViewport

var active_vignette: Node3D


func _ready() -> void:
    GameModeSignalBus.conversation_triggered.connect(_on_conversation_started)
    hide()

func _process(_delta: float) -> void:
    if visible && Input.is_key_pressed(KEY_SPACE):
        active_vignette.queue_free()
        get_tree().paused = false
        hide()
        GameModeSignalBus.combat_triggered.emit()
    if Input.is_key_pressed(KEY_R):
        get_tree().paused = false
        get_tree().reload_current_scene()


func _on_conversation_started(vignette_instance: Node3D):
    vignette_viewport.add_child(vignette_instance)
    active_vignette = vignette_instance
    view.start_display()
    show()
