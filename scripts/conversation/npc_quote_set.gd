class_name NPCQuoteSet

var initial_prompt: String
var neutral_quotes: RandomNonRepeatingArray
var positive_quotes: RandomNonRepeatingArray
var negative_quotes: RandomNonRepeatingArray
var success_quote: String
var failure_quote: String


func _init(dialogue: NPCDialogue):
    initial_prompt = dialogue.initial_prompt
    positive_quotes = RandomNonRepeatingArray.new(
        dialogue.positive_quote_block.split('\n')
    )
    neutral_quotes = RandomNonRepeatingArray.new(
        dialogue.neutral_quote_block.split('\n')
    )
    negative_quotes = RandomNonRepeatingArray.new(
        dialogue.negative_quote_block.split('\n')
    )
    success_quote = dialogue.success_quote
    failure_quote = dialogue.failure_quote


func get_quote(response: ResponseValues) -> String:
    match response.success_level:
        ResponseValues.NEGATIVE: return negative_quotes.pick_new()
        ResponseValues.POSITIVE: return positive_quotes.pick_new()
    return neutral_quotes.pick_new()
