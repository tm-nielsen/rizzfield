class_name ResponseValueDisplay
extends Control

@export_subgroup("response value labels", "response_label")
@export var response_label_chastity: Label
@export var response_label_temperance: Label
@export var response_label_humility: Label
@export var response_label_patience: Label

@export_subgroup("held fragment labels", "fragment_label")
@export var fragment_label_chastity: Label
@export var fragment_label_temperance: Label
@export var fragment_label_humility: Label
@export var fragment_label_patience: Label

@export_subgroup("colours", "colour")
@export var colour_neutral = Color.WHITE
@export var colour_positive = Color.LIGHT_GREEN
@export var colour_negative = Color.LIGHT_PINK
@export var colour_disabled = Color.DARK_GRAY

var held_fragment: ResponseFragment = null

var chastity_enabled: bool
var temperance_enabled: bool
var humility_enabled: bool
var patience_enabled: bool


func _ready() -> void:
    ResponseBuilderSignalBus.fragment_body_grabbed.connect(
        func(fragment: ResponseFragment):
        held_fragment = fragment
        display_fragment_values(fragment)
    )
    ResponseBuilderSignalBus.fragment_body_dropped.connect(
        func(_fragment: ResponseFragment):
        held_fragment = null
    )
    ResponseBuilderSignalBus.mouse_entered_fragment_body.connect(
        func(fragment: ResponseFragment):
        if !held_fragment: display_fragment_values(fragment)
    )
    ResponseBuilderSignalBus.mouse_exited_fragment_body.connect(
        func(_fragment: ResponseFragment):
        if !held_fragment: hide_fragment_value_display()
    )


func initialize_displays(stats: ConversationStatSet):
    chastity_enabled = initialize_displays_for_stat(
        [response_label_chastity, fragment_label_chastity],
        stats.chastity, func(): chastity_enabled = false
    )
    temperance_enabled = initialize_displays_for_stat(
        [response_label_temperance, fragment_label_temperance],
        stats.temperance, func(): temperance_enabled = false
    )
    humility_enabled = initialize_displays_for_stat(
        [response_label_humility, fragment_label_humility],
        stats.humility, func(): humility_enabled = false
    )
    patience_enabled = initialize_displays_for_stat(
        [response_label_patience, fragment_label_patience],
        stats.patience, func(): patience_enabled = false
    )

func initialize_displays_for_stat(
    displays: Array[Label], stat: ConversationStat, set_flag: Callable
) -> bool:
    var stat_enabled = !stat.disabled
    var disable_displays = func():
        set_flag.call()
        for label in displays:
            label.modulate = colour_disabled
            label.text = "--"

    if !stat_enabled: disable_displays.call()
    else: stat.filled.connect(disable_displays)
    return stat_enabled


func display_fragment_values(fragment: ResponseFragment):
    show_fragment_value_display()
    display_stat_values(
        fragment.chastity, fragment.temperance,
        fragment.humility, fragment.patience,
        fragment_label_chastity, fragment_label_temperance,
        fragment_label_humility, fragment_label_patience
    )

func show_fragment_value_display():
    for label in [
        fragment_label_chastity, fragment_label_temperance,
        fragment_label_humility, fragment_label_patience
    ]: label.show()

func hide_fragment_value_display():
    for label in [
        fragment_label_chastity, fragment_label_temperance,
        fragment_label_humility, fragment_label_patience
    ]: label.hide()

func display_response_values(values: ResponseValues):
    display_stat_values(
        values.chastity, values.temperance,
        values.humility, values.patience,
        response_label_chastity, response_label_temperance,
        response_label_humility, response_label_patience
    )

func display_stat_values(
    chastity: int, temperance: int,
    humility: int, patience: int,
    chastity_label: Label, temperance_label: Label,
    humility_label: Label, patience_label: Label
):
    if chastity_enabled: display_value(chastity_label, chastity)
    if temperance_enabled: display_value(temperance_label, temperance)
    if humility_enabled: display_value(humility_label, humility)
    if patience_enabled: display_value(patience_label, patience)

func display_value(label: Label, value: int):
    label.text = get_value_string(value)
    label.modulate = get_value_colour(value)

func get_value_colour(value: int) -> Color:
    if value > 0: return colour_positive
    if value < 0: return colour_negative
    return colour_neutral

static func get_value_string(value: int) -> String:
    var prefix := "+" if value > 0 else ""
    return prefix + str(value)
