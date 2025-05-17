class_name ConversationStatSet

signal all_stats_filled
signal stat_emptied

var chastity: ConversationStat
var temperance: ConversationStat
var humility: ConversationStat
var patience: ConversationStat

var stat_array: Array[ConversationStat]: get=_get_stat_array
var is_full: bool
var failed: bool


func _init(
    p_chastity: ConversationStat, p_temperance: ConversationStat,
    p_humility: ConversationStat, p_patience: ConversationStat
):
    chastity = p_chastity
    temperance = p_temperance
    humility = p_humility
    patience = p_patience
    for stat in stat_array:
        stat.emptied.connect(func():
            failed = true
            stat_emptied.emit()
        )


func update_values(response: ResponseValues):
    chastity.update_value(response.chastity)
    temperance.update_value(response.temperance)
    humility.update_value(response.humility)
    patience.update_value(response.patience)
    if stat_array.all(func(stat): return stat.is_full):
        is_full = true
        all_stats_filled.emit()


func get_next_values(values := ResponseValues.new()) -> ResponseValues:
    return ResponseValues.new(
        values.chastity - chastity.next_drain,
        values.temperance - temperance.next_drain,
        values.humility - humility.next_drain,
        values.patience - patience.next_drain
    )

func get_total_response_delta(values : ResponseValues) -> int:
    return [
        [chastity, values.chastity], [temperance, values.temperance],
        [humility, values.humility], [patience, values.patience]
    ].reduce(
        func(total: int, stat_and_value):
        var stat: ConversationStat = stat_and_value[0]
        if stat.disabled || stat.is_full: return total
        return total + stat_and_value[1] - stat.next_drain,
        0
    )


func _get_stat_array() -> Array:
    return [
        chastity, temperance, humility, patience
    ].filter(func(stat): return stat.value > 0)
