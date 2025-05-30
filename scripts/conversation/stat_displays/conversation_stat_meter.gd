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

@export_subgroup("elasticity", "elastic")
@export var elastic_fill_level: ElasticValue
@export var elastic_preview_level: ElasticValue

var fill_target: float
var preview_target: float

var offset_state: OffsetState
var stat: ConversationStat


func _process(delta: float) -> void:
    var delta_scale = delta * ElasticValue.SCALING_FRAMERATE
    elastic_fill_level.update_value(fill_target, delta_scale)
    elastic_preview_level.update_value(preview_target, delta_scale)
    fill.anchor_bottom = 1
    fill.anchor_top = clampf(1 - elastic_fill_level.value, 0, 1)
    _update_preview()


func setup(p_stat: ConversationStat):
    stat = p_stat
    _setup_elastic_values(stat.get_normalized_value())
    fill.anchor_top = 0.0 if stat.is_disabled else 2 * (1 - fill_target)
    fill.color = colour_disabled if stat.is_disabled else Color.WHITE
    preview.color = Color.TRANSPARENT

func _setup_elastic_values(initial_value: float):
    elastic_fill_level = elastic_fill_level.duplicate()
    elastic_preview_level = elastic_preview_level.duplicate()
    fill_target = initial_value
    preview_target = fill_target
    elastic_fill_level.value = fill_target
    elastic_preview_level.value = fill_target


func update(response_value: int, apply_value := false) -> void:
    if stat.is_disabled: return
    _update_targets(response_value, apply_value)
    _update_offset_state()
    fill.color = colour_fill_gradient.sample(elastic_fill_level.value)
    preview.color = _get_preview_colour()

func _update_targets(response_value: int, apply_value := false) -> void:
    fill_target = stat.get_normalized_value()
    preview_target = (
        fill_target if apply_value || stat.is_full
        else stat.get_normalized_next_value(response_value)
    )

func _update_offset_state() -> void:
    if is_equal_approx(preview_target, fill_target):
        offset_state = EQUAL
    elif preview_target > fill_target:
        offset_state = POSITIVE
    elif preview_target < fill_target:
        offset_state = NEGATIVE


func _update_preview() -> void:
    var is_positive = offset_state == POSITIVE
    var top_anchor := clampf(1 - (
        elastic_preview_level.value
        if is_positive
        else elastic_fill_level.value
    ), 0, 1)
    var bottom_anchor := clampf(1 - (
        elastic_fill_level.value
        if is_positive
        else elastic_preview_level.value
    ), 0, 1)
    preview.anchor_top = clampf(top_anchor, 0, bottom_anchor)
    preview.anchor_bottom = clampf(bottom_anchor, top_anchor, 1)

func _get_preview_colour() -> Color:
    match offset_state:
        POSITIVE: return colour_positive
        NEGATIVE: return colour_negative
    return Color.TRANSPARENT
