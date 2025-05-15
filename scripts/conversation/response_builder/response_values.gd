class_name ResponseValues
var chastity: int = 0
var temperance: int = 0
var humility: int = 0
var patience: int = 0

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
