class_name ConversationStatSet

signal all_stats_filled
signal stat_emptied

var chastity: ConversationStat
var temperance: ConversationStat
var humility: ConversationStat
var patience: ConversationStat

var stat_array: Array[ConversationStat]: get=_get_stat_array


func _init(
    p_chastity: ConversationStat, p_temperance: ConversationStat,
    p_humility: ConversationStat, p_patience: ConversationStat
):
    chastity = p_chastity
    temperance = p_temperance
    humility = p_humility
    patience = p_patience
    for stat in stat_array:
        stat.emptied.connect(stat_emptied.emit)


func update_values(response: ResponseBuilder.ResponseValues):
    chastity.update_value(response.chastity)
    temperance.update_value(response.temperance)
    humility.update_value(response.humility)
    patience.update_value(response.patience)
    if stat_array.all(func(stat): return stat.is_full):
        all_stats_filled.emit()
    

func _get_stat_array() -> Array:
    return [
        chastity, temperance, humility, patience
    ].filter(func(stat): return stat.value > 0)
