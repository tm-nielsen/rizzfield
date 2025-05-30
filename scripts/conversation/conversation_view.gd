class_name ConversationView
extends Control

signal npc_spoke

@export var display_area: Control
@export var construction_area: Control
@export var dialogue_area: Control
@export var vignette_container: SubViewportContainer
@export var primary_dialogue_box: Label
@export var secondary_dialogue_box: Label

@export_subgroup("fonts", "font")
@export var font_npc_quote: Font
@export var font_narration: Font
@export var font_size_npc: int = 24
@export var font_size_narration: int = 18

@export_subgroup("tweens")
@export var active_area_focused_size: float = 1.8
@export_subgroup("tweens/appear", "appear_shrink")
@export var appear_shrink_delay: float = 0.5
@export var appear_shrink_duration: float = 0.4
@export_subgroup("tweens/response construction", "response_construction")
@export var response_construction_grow_duration: float = 0.2
@export_subgroup("tweens/response display", "response_display")
@export var response_display_grow_size: float = 2.2
@export var response_display_shrink_duration: float = 0.5
@export_subgroup("tweens/speak", "speak")
@export var speak_grow_duration: float = 0.2
@export var speak_shrink_duration: float = 0.4


func _ready() -> void:
    for node in [display_area, construction_area, dialogue_area, vignette_container]:
        _set_stretch_ratio(1, node)

func start_prompt_display(prompt: String):
    _display_dialogue(prompt, font_npc_quote, font_size_npc)
    vignette_container.custom_minimum_size = get_viewport_rect().size;
    var tween = TweenHelpers.build_tween(self, appear_shrink_delay)
    tween.tween_property(
        vignette_container, "custom_minimum_size",
        Vector2.ZERO, appear_shrink_duration
    )
    tween.set_parallel()
    _tween_stretch_ratio(
        vignette_container, 1,
        appear_shrink_duration,
        _tween_stretch_ratio(
            display_area, 1,
            appear_shrink_duration,
            tween, 2
        ), 2
    )
    npc_spoke.emit()


func start_response_construction():
    dialogue_area.hide()
    construction_area.show()
    _tween_stretch_ratio(
        construction_area,
        active_area_focused_size,
        response_construction_grow_duration
    )
    _tween_stretch_ratio(
        vignette_container, 1,
        speak_shrink_duration,
        _tween_stretch_ratio(
            display_area, 1,
            speak_shrink_duration
        ).set_parallel()
    )


func display_constructed_response(response: String):
    _display_dialogue(
        response, font_narration,
        font_size_narration, false
    )
    _tween_stretch_ratio(
        dialogue_area,
        active_area_focused_size,
        response_display_shrink_duration,
        TweenHelpers.build_tween(self),
        response_display_grow_size
    )


func display_npc_quote(quote: String):
    _display_dialogue(quote, font_npc_quote, font_size_npc)
    _tween_stretch_ratio(
        vignette_container, 2,
        speak_grow_duration,
        _tween_stretch_ratio(
            display_area, 2,
            speak_grow_duration
        ).set_parallel()
    )
    npc_spoke.emit()

func _display_dialogue(
    text: String, font: Font, font_size: int,
    set_secondary := true
):
    construction_area.hide()
    dialogue_area.show()
    primary_dialogue_box.text = text
    primary_dialogue_box.label_settings.font = font
    primary_dialogue_box.label_settings.font_size = font_size
    if set_secondary:
        secondary_dialogue_box.text = text


func _tween_stretch_ratio(
    target: Control, final_value: float, duration: float,
    tween := TweenHelpers.build_tween(self),
    initial_value := target.size_flags_stretch_ratio
) -> Tween:
    _set_stretch_ratio(initial_value, target)
    tween.tween_method(
        _set_stretch_ratio.bind(target),
        initial_value, final_value, duration
    )
    return tween

func _set_stretch_ratio(value: float, target: Control):
    target.size_flags_stretch_ratio = value
