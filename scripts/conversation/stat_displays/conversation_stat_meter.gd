class_name ConversationStatMeter
extends Control

enum OffsetState { EQUAL, POSITIVE, NEGATIVE }
const EQUAL = OffsetState.EQUAL
const POSITIVE = OffsetState.POSITIVE
const NEGATIVE = OffsetState.NEGATIVE

@export var fill: ColorRect
@export var preview: ColorRect

@export_subgroup("colours", "colour")
@export var colour_fill_gradient: Gradient
@export var colour_positive = Color.LIGHT_GREEN
@export var colour_negative = Color.LIGHT_PINK
@export var colour_disabled = Color.DARK_GRAY

var fill_level: float
var preview_level: float
var offset_state: OffsetState

var stat: ConversationStat


func _process(_delta: float) -> void:
    fill.anchor_top = 1 - fill_level
    _update_preview()


func setup(p_stat: ConversationStat):
    stat = p_stat
    fill_level = stat.get_normalized_value()
    preview_level = fill_level
    fill.anchor_top = 0.0 if stat.disabled else 2 * (1 - fill_level)
    fill.color = colour_disabled if stat.disabled else Color.WHITE
    preview.color = Color.TRANSPARENT


func update(response_value: int, apply_value := false) -> void:
    if stat.disabled: return
    _update_targets(response_value, apply_value)
    _update_offset_state()
    fill.color = colour_fill_gradient.sample(fill_level)
    preview.color = _get_preview_colour()

func _update_targets(response_value: int, apply_value := false) -> void:
    fill_level = stat.get_normalized_value()
    preview_level = (
        fill_level if apply_value || stat.is_full
        else stat.get_normalized_next_value(response_value)
    )

func _update_offset_state() -> void:
    if is_equal_approx(preview_level, fill_level):
        offset_state = EQUAL
    elif preview_level > fill_level:
        offset_state = POSITIVE
    elif preview_level < fill_level:
        offset_state = NEGATIVE


func _update_preview() -> void:
    var is_positive = offset_state == POSITIVE
    preview.anchor_top = 1 - (
        preview_level if is_positive
        else fill_level
    )
    preview.anchor_bottom = 1 - (
        fill_level if is_positive
        else preview_level
    )

func _get_preview_colour() -> Color:
    match offset_state:
        POSITIVE: return colour_positive
        NEGATIVE: return colour_negative
    return Color.TRANSPARENT
