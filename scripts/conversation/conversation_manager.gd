extends Control

@export_subgroup("vignette", "vignette")
@export var vignette_container: SubViewportContainer
@export var vignette_viewport: SubViewport
@export_subgroup("vignette/tweens", "vignette")
@export_subgroup("vignette/tweens/appear", "vignette_appear_shrink")
@export var vignette_appear_shrink_delay: float = 0.8
@export var vignette_appear_shrink_duration: float = 0.4
@export_subgroup("vignette/tweens/speak", "vignette_speak")
@export var vignette_speak_grow_duration: float = 0.2
@export var vignette_speak_shrink_duration: float = 0.4

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
    vignette_container.custom_minimum_size = get_viewport_rect().size;
    var tween := create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_interval(vignette_appear_shrink_delay)
    tween.tween_property(
        vignette_container, "custom_minimum_size",
        Vector2.ZERO, vignette_appear_shrink_duration
    )
    show()
