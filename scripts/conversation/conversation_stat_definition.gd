class_name ConversationStatDefinition
extends Resource
@export var name: String
@export var initial_value: int = 10
@export var maximum_value: int = 20
@export var decrement: int = 4
@export var decrement_variation: int = 2


func get_next_decrement() -> int:
    return decrement + randi_range(
        -decrement_variation,
        decrement_variation
    )


class ConversationStat:
    signal filled
    signal emptied

    var definition: ConversationStatDefinition
    var name: String
    var value: int
    var is_full: bool
    var next_decrement: int


    func _init(source: ConversationStatDefinition):
        definition = source
        name = definition.name
        value = definition.initial_value

    func update_value(increment: int):
        if is_full: return
        value += increment - next_decrement
        next_decrement = definition.get_next_decrement()
        _process_state()

    func _process_state():
        if value >= definition.maximum_value:
            is_full = true
            filled.emit()
        if value <= 0:
            emptied.emit()
        
