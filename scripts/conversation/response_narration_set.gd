class_name ResponseNarrationSet

const RESULT_TEXT = {
    ResponseValues.NEGATIVE: "That didn't work.",
    ResponseValues.NEUTRAL: "It seems fine.",
    ResponseValues.POSITIVE: "They liked that!"
}

var chastity_actions: RandomNonRepeatingArray
var temperance_actions: RandomNonRepeatingArray
var humility_actions: RandomNonRepeatingArray
var patience_actions: RandomNonRepeatingArray


func _init(
    default_chastity_actions: Array[String],
    default_temperance_actions: Array[String],
    default_humility_actions: Array[String],
    default_patience_actions: Array[String]
):
    chastity_actions = RandomNonRepeatingArray.new(default_chastity_actions)
    temperance_actions = RandomNonRepeatingArray.new(default_temperance_actions)
    humility_actions = RandomNonRepeatingArray.new(default_humility_actions)
    patience_actions = RandomNonRepeatingArray.new(default_patience_actions)


func build_response_text(
    response: ResponseValues, stats: ConversationStatSet
) -> String:
    var maximum = response.get_maximum_affecting_value(stats)
    var relevant_pools: Array[RandomNonRepeatingArray] = []

    if response.chastity == maximum && stats.chastity.is_active:
        relevant_pools.append(chastity_actions)
    if response.temperance == maximum && stats.temperance.is_active:
        relevant_pools.append(temperance_actions)
    if response.humility == maximum && stats.humility.is_active:
        relevant_pools.append(humility_actions)
    if response.patience == maximum && stats.patience.is_active:
        relevant_pools.append(patience_actions)

    return (
        "You " + relevant_pools.pick_random().pick_new()
        + "\n" + RESULT_TEXT[response.success_level]
    )
