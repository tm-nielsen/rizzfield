class_name NPCDialogueSet
extends Resource

@export_multiline var initial_prompt: String
@export_multiline var success_quote: String
@export_multiline var failure_quote: String
@export_subgroup("responses")
@export_multiline var positive_quote_block: String
@export_multiline var neutral_quote_block: String
@export_multiline var negative_quote_block: String

var neutral_responses: RandomNonRepeatingArray
var positive_responses: RandomNonRepeatingArray
var negative_responses: RandomNonRepeatingArray


func create_instance() -> NPCDialogueSet:
    var instance = duplicate()
    instance.positive_responses = _split_quote_block(positive_quote_block)
    instance.neutral_responses = _split_quote_block(neutral_quote_block)
    instance.negative_responses = _split_quote_block(negative_quote_block)
    return instance


func get_quote_for_response(response: ResponseValues) -> String:
    match response.success_level:
        ResponseValues.NEGATIVE: return negative_responses.pick_new()
        ResponseValues.POSITIVE: return positive_responses.pick_new()
    return neutral_responses.pick_new()


func _split_quote_block(quote_block: String) -> RandomNonRepeatingArray:
    return RandomNonRepeatingArray.new(quote_block.split('\n'))
