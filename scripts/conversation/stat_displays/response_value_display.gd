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

var held_fragment: ResponseFragment = null


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
    chastity_label.text = get_value_string(chastity)
    temperance_label.text = get_value_string(temperance)
    humility_label.text = get_value_string(humility)
    patience_label.text = get_value_string(patience)

static func get_value_string(value: int) -> String:
    var prefix := "+" if value > 0 else ""
    return prefix + str(value)
