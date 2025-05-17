class_name ResponseValues

enum SuccessLevel { NEGATIVE, NEUTRAL, POSITIVE }
const NEGATIVE = SuccessLevel.NEGATIVE
const NEUTRAL = SuccessLevel.NEUTRAL
const POSITIVE = SuccessLevel.POSITIVE

var chastity: int = 0
var temperance: int = 0
var humility: int = 0
var patience: int = 0

var success_level: SuccessLevel
var total_value: int


func _init(
    p_chastity: int = 0, p_temperance: int = 0,
    p_humility: int = 0, p_patience: int = 0
) -> void:
    chastity = p_chastity
    temperance = p_temperance
    humility = p_humility
    patience = p_patience

func duplicate() -> ResponseValues:
    return ResponseValues.new(
        chastity, temperance, humility, patience
    )

func add(fragment: ResponseFragment):
    chastity += fragment.chastity
    temperance += fragment.temperance
    humility += fragment.humility
    patience += fragment.patience


func evaluate(stats: ConversationStatSet,
    negative_threshold: int, positive_threshold: int
):
    total_value = stats.get_total_response_value(self)
    if total_value < negative_threshold:
        success_level = NEGATIVE
    elif total_value > positive_threshold:
        success_level = POSITIVE
    else:
        success_level = NEUTRAL


func get_maximum_affecting_value(
    stats: ConversationStatSet
) -> int:
    var affecting_values = []
    if stats.chastity.is_active: affecting_values.append(chastity)
    if stats.temperance.is_active: affecting_values.append(temperance)
    if stats.humility.is_active: affecting_values.append(humility)
    if stats.patience.is_active: affecting_values.append(patience)
    return affecting_values.max()
