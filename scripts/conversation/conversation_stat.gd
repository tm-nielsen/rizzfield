class_name ConversationStat

signal filled
signal emptied

var name: String
var value: int
var is_full: bool

var maximum_value: int
var drain: int
var drain_variation: int

var next_drain: int

func _init(
    p_name: String,
    initial_value: int, p_maximum_value: int,
    p_drain: int, p_drain_variation: int, 
):
    name = p_name
    value = initial_value
    maximum_value = p_maximum_value
    drain = p_drain
    drain_variation = p_drain_variation
    _set_next_drain()


func update_value(amount_added: int) -> void:
    if is_full: return
    value += amount_added - next_drain
    _set_next_drain()
    _process_state()

func _set_next_drain() -> void:
    next_drain = drain + randi_range(
        -drain_variation,
        drain_variation
    )

func _process_state() -> void:
    if value >= maximum_value:
        is_full = true
        filled.emit()
    elif value <= 0:
        emptied.emit()


func get_normalized_value() -> float:
    return clampf(float(value) / maximum_value, 0, 1)

func get_normalized_next_value(offset: int = 0) -> float:
    return clampf(float(value + offset - next_drain) / maximum_value, 0, 1)
