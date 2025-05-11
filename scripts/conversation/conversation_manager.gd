extends Control

enum ConversationState {
    INACTIVE, PROMPT_DISPLAY, QUOTE_DISPLAY,
    RESPONSE_CONSTRUCTION, RESPONSE_DISPLAY
}
const INACTIVE = ConversationState.INACTIVE
const PROMPT_DISPLAY = ConversationState.PROMPT_DISPLAY
const QUOTE_DISPLAY = ConversationState.QUOTE_DISPLAY
const RESPONSE_CONSTRUCTION = ConversationState.RESPONSE_CONSTRUCTION
const RESPONSE_DISPLAY = ConversationState.RESPONSE_DISPLAY

@export var view: ConversationView
@export var vignette_viewport: SubViewport
@export var response_construction_timer: ResponseTimer
@export var response_builder: ResponseBuilder
@export var submit_response_button: Button

@export_subgroup("timing", "duration")
@export var duration_prompt_display: float = 3
@export var duration_response_construction: float = 8
@export var duration_response_display: float = 2
@export var duration_quote_display: float = 2

var state: ConversationState
var vignette: Node3D
var dialogue: DialogueSet
var stats: ConversationStatSet


func _ready() -> void:
    GameModeSignalBus.conversation_triggered.connect(_on_conversation_started)
    response_construction_timer.timeout.connect(_submit_response)
    submit_response_button.pressed.connect(_submit_response)
    submit_response_button.disabled = true
    hide()

func _process(_delta: float) -> void:
    if state == RESPONSE_CONSTRUCTION:
        submit_response_button.disabled = response_builder.is_blank


func set_state(new_state: ConversationState):
    state = new_state
    match state:
        INACTIVE: hide()
        PROMPT_DISPLAY:
            view.start_prompt_display(dialogue.initial_prompt)
            set_state_in(RESPONSE_CONSTRUCTION, duration_prompt_display)
            show()
        RESPONSE_CONSTRUCTION:
            view.start_response_construction()
            response_builder.reset()
            response_construction_timer.start(duration_response_construction)
        QUOTE_DISPLAY:
            set_state_in(RESPONSE_CONSTRUCTION, duration_quote_display)

func set_state_in(target_state: ConversationState, delay: float):
    TweenHelpers.call_delayed_realtime(
        set_state.bind(target_state), delay
    )


func _on_conversation_started(
    definition: ConversationDefinition,
    vignette_instance: Node3D
):
    dialogue = definition.get_dialogue_set()
    stats = definition.get_stat_set()
    stats.all_stats_filled.connect(
        end_conversation.bind(GameModeSignalBus.notify_conversation_resolved)
    )
    stats.stat_emptied.connect(
        end_conversation.bind(GameModeSignalBus.notify_combat_triggered)
    )
    vignette = vignette_instance
    vignette_viewport.add_child(vignette)
    set_state(PROMPT_DISPLAY)

func end_conversation(notification_method: Callable):
    if state == INACTIVE: return
    state = INACTIVE
    vignette.queue_free()
    hide()
    notification_method.call()


func _submit_response():
    response_construction_timer.cancel()
    var response_values := response_builder.get_response_values()
    stats.update_values(response_values)
    if stats.is_full || stats.failed: return

    view.display_constructed_response("response narration")
    state = RESPONSE_DISPLAY
    TweenHelpers.call_delayed_realtime(
        func():
        set_state(QUOTE_DISPLAY)
        view.display_npc_quote(dialogue.neutral_quotes.pick_random())
        , duration_response_display
    )
