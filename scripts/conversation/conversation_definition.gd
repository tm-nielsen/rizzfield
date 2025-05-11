@tool
class_name ConversationDefinition
extends Resource

@export var vignette_prefab: PackedScene
@export_file("*.txt") var dialogue_file: String

@export_subgroup("stats")
@export_subgroup("stats/chastity", "chastity")
@export var chastity_initial_value: int = 10
@export var chastity_maximum_value: int = 20
@export var chastity_drain: int = 4
@export var chastity_drain_variation: int = 2

@export_subgroup("stats/temperance", "temperance")
@export var temperance_initial_value: int = 10
@export var temperance_maximum_value: int = 20
@export var temperance_drain: int = 4
@export var temperance_drain_variation: int = 2

@export_subgroup("stats/humility", "humility")
@export var humility_initial_value: int = 0
@export var humility_maximum_value: int = 20
@export var humility_drain: int = 4
@export var humility_drain_variation: int = 2

@export_subgroup("stats/patience", "patience")
@export var patience_initial_value: int = 0
@export var patience_maximum_value: int = 20
@export var patience_drain: int = 4
@export var patience_drain_variation: int = 2


func get_stat_set() -> ConversationStatSet:
    return ConversationStatSet.new(
        ConversationStat.new("Chastity",
            chastity_initial_value, chastity_maximum_value,
            chastity_drain, chastity_drain_variation
        ),
        ConversationStat.new("Temperance",
            temperance_initial_value, temperance_maximum_value,
            temperance_drain, temperance_drain_variation
        ),
        ConversationStat.new("Humility",
            humility_initial_value, humility_maximum_value,
            humility_drain, humility_drain_variation
        ),
        ConversationStat.new("Patience",
            patience_initial_value, patience_maximum_value,
            patience_drain, patience_drain_variation
        )
    )

func get_dialogue_set() -> DialogueSet:
    return DialogueSet.new(dialogue_file)
