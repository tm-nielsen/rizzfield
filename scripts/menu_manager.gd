extends Control

@export var main_menu: Control
@export var death_screen: Control
@export var death_screen_label: RichTextLabel
@export var death_screen_type_duration: float = 2
@export var death_screen_display_duration: float = 3


func _ready() -> void:
    GameModeSignalBus.player_died.connect(start_death_screen_sequence)
    show()
    main_menu.show()
    death_screen.hide()


func start_game():
    GameModeSignalBus.notify_game_started()
    main_menu.hide()

func start_death_screen_sequence():
    death_screen_label.visible_ratio = 0
    death_screen.show()
    var death_screen_tween = create_tween()
    death_screen_tween.tween_property(
        death_screen_label, "visible_ratio", 1.0,
        death_screen_type_duration
    )
    death_screen_tween.tween_interval(
        death_screen_display_duration
    )
    death_screen_tween.tween_callback(
        get_tree().reload_current_scene
    )
