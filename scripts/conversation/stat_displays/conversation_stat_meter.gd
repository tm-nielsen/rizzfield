class_name ConversationStatMeter
extends Control

@export var fill: ColorRect
@export var preview: ColorRect

@export_subgroup("colours", "colour")
@export var colour_fill_gradient: Gradient
@export var colour_positive = Color.LIGHT_GREEN
@export var colour_negative = Color.LIGHT_PINK
@export var colour_disabled = Color.DARK_GRAY

var stat: ConversationStat
var disabled: bool


func setup(p_stat: ConversationStat):
    stat = p_stat
    disabled = stat.value == 0
    fill.anchor_top = 0.0 if disabled else (1 - stat.get_normalized_value())
    fill.color = colour_disabled if disabled else Color.WHITE
    preview.visible = !disabled


func update(response_value: int) -> void:
    if disabled: return
    if stat.is_full: return
    var fill_level = stat.get_normalized_value()
    var preview_level = stat.get_normalized_next_value(response_value)
    var is_positive = preview_level > fill_level

    fill.anchor_top = 1 - fill_level
    preview.anchor_top = 1 - (preview_level if is_positive else fill_level)
    preview.anchor_bottom = 1 - (fill_level if is_positive else preview_level)

    fill.color = colour_fill_gradient.sample(fill_level)
    preview.color = colour_positive if is_positive else colour_negative
    
    