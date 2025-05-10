class_name ConversationView
extends Control

@export var display_area: Control
@export var active_area: Control

@export_subgroup("vignette", "vignette")
@export var vignette_container: SubViewportContainer
@export_subgroup("vignette/tweens", "vignette")
@export_subgroup("vignette/tweens/appear", "vignette_appear_shrink")
@export var vignette_appear_shrink_delay: float = 0.5
@export var vignette_appear_shrink_duration: float = 0.4
@export_subgroup("vignette/tweens/speak", "vignette_speak")
@export var vignette_speak_grow_duration: float = 0.2
@export var vignette_speak_shrink_duration: float = 0.4


func start_prompt_display():
    vignette_container.custom_minimum_size = get_viewport_rect().size;
    vignette_container.size_flags_stretch_ratio = 2
    display_area.size_flags_stretch_ratio = 2;

    var tween = TweenHelpers.build_tween(vignette_appear_shrink_delay)
    tween.bind_node(self)
    tween.tween_property(
        vignette_container, "custom_minimum_size",
        Vector2.ZERO, vignette_appear_shrink_duration
    )
    tween.set_parallel()
    tween.tween_property(
        vignette_container, "size_flags_stretch_ratio",
        1, vignette_appear_shrink_duration
    )
    tween.tween_property(
        display_area, "size_flags_stretch_ratio",
        1, vignette_appear_shrink_duration
    )


func start_response_construction():
    pass


func display_constructed_response(response: String):
    pass


func display_npc_quote(quote: String):
    pass
