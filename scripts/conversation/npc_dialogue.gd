class_name NPCDialogue
extends Resource

@export_multiline var initial_prompt: String
@export_multiline var success_quote: String
@export_multiline var failure_quote: String
@export_subgroup("responses")
@export_multiline var positive_quote_block: String
@export_multiline var neutral_quote_block: String
@export_multiline var negative_quote_block: String
