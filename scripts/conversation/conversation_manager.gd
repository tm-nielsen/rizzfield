extends Control

enum ConversationState {
    INACTIVE, PROMPT_DISPLAY, QUOTE_DISPLAY,
    RESPONSE_CONSTRUCTION, RESPONSE_DISPLAY,
    FINAL_QUOTE_DISPLAY
}
const INACTIVE = ConversationState.INACTIVE
const PROMPT_DISPLAY = ConversationState.PROMPT_DISPLAY
const QUOTE_DISPLAY = ConversationState.QUOTE_DISPLAY
const RESPONSE_CONSTRUCTION = ConversationState.RESPONSE_CONSTRUCTION
const RESPONSE_DISPLAY = ConversationState.RESPONSE_DISPLAY
const FINAL_QUOTE_DISPLAY = ConversationState.FINAL_QUOTE_DISPLAY

@export var view: ConversationView
@export var vignette_viewport: SubViewport
@export var response_construction_timer: ResponseTimer
@export var response_builder: ResponseBuilder
@export var response_value_display: ResponseValueDisplay
@export var submit_response_button: Button

@export_subgroup("timing", "duration")
@export var duration_prompt_display: float = 3
@export var duration_response_construction: float = 8
@export var duration_response_display: float = 2
@export var duration_quote_display: float = 2
@export var duration_final_quote_display: float = 2

@export_subgroup("success levels")
@export var negative_response_threshold: int = 0
@export var positive_response_threshold: int = 3

@export_subgroup("stat meters")
@export var chastity_meter: ConversationStatMeter
@export var temperance_meter: ConversationStatMeter
@export var humility_meter: ConversationStatMeter
@export var patience_meter: ConversationStatMeter

@export_subgroup("response narration", "default_action")
@export var default_action_chastity: String
@export var default_action_temperance: String
@export var default_action_humility: String
@export var default_action_patience: String

var state: ConversationState
var vignette: Node3D
var npc_dialogue_set: NPCDialogueSet
var response_narration_set: ResponseNarrationSet
var stats: ConversationStatSet

var state_tween: Tween


func _ready() -> void:
    GameModeSignalBus.conversation_triggered.connect(_on_conversation_started)
    GameModeSignalBus.conversation_ended.connect(disable)
    response_construction_timer.timeout.connect(_submit_response)
    response_builder.response_modified.connect(_on_response_modified)
    submit_response_button.pressed.connect(_submit_response)
    response_narration_set = ResponseNarrationSet.new(
        [default_action_chastity], [default_action_temperance],
        [default_action_humility], [default_action_patience]
    )
    set_state(INACTIVE)


func set_state(new_state: ConversationState):
    state = new_state
    match state:
        INACTIVE: hide()
        PROMPT_DISPLAY:
            view.start_prompt_display(npc_dialogue_set.initial_prompt)
            response_value_display.hide_fragment_value_display()
            set_state_in(RESPONSE_CONSTRUCTION, duration_prompt_display)
            show()
        RESPONSE_CONSTRUCTION:
            view.start_response_construction()
            submit_response_button.disabled = true
            response_builder.reset()
            response_value_display.display_response_values(stats.get_next_values())
            response_construction_timer.start(duration_response_construction)
            _update_stat_meters()
        QUOTE_DISPLAY:
            set_state_in(RESPONSE_CONSTRUCTION, duration_quote_display)

func set_state_in(target_state: ConversationState, delay: float):
    if state_tween: state_tween.kill()
    state_tween = TweenHelpers.call_delayed_realtime(
        set_state.bind(target_state), delay
    )


func _on_conversation_started(
    definition: ConversationDefinition,
    vignette_instance: Node3D
):
    npc_dialogue_set = definition.get_dialogue_set()
    _initialize_stat_set(definition)
    vignette = vignette_instance
    vignette_viewport.add_child(vignette)
    set_state(PROMPT_DISPLAY)

func _initialize_stat_set(conversation_definition: ConversationDefinition):
    stats = conversation_definition.get_stat_set()
    stats.all_stats_filled.connect(
        end_conversation.bind(
            npc_dialogue_set.success_quote,
            GameModeSignalBus.notify_conversation_resolved
        )
    )
    stats.stat_emptied.connect(
        end_conversation.bind(
            npc_dialogue_set.failure_quote,
            GameModeSignalBus.notify_combat_triggered
        )
    )
    chastity_meter.setup(stats.chastity)
    temperance_meter.setup(stats.temperance)
    humility_meter.setup(stats.humility)
    patience_meter.setup(stats.patience)
    response_value_display.initialize_displays(stats)

func _on_response_modified(response: ResponseValues):
    submit_response_button.disabled = response_builder.is_blank
    _update_stat_meters(response)
    response_value_display.display_response_values(
        stats.get_next_values(response)
    )

func _update_stat_meters(
    response := ResponseValues.new(),
    apply_response := false
):
    chastity_meter.update(response.chastity, apply_response)
    temperance_meter.update(response.temperance, apply_response)
    humility_meter.update(response.humility, apply_response)
    patience_meter.update(response.patience, apply_response)


func end_conversation(
    final_quote: String,
    notification_method: Callable
):
    if state == FINAL_QUOTE_DISPLAY: return
    set_state(FINAL_QUOTE_DISPLAY)
    view.display_npc_quote(final_quote)
    TweenHelpers.call_delayed_realtime(
        notification_method.call
        , duration_final_quote_display
    )

func disable():
    if state_tween: state_tween.kill()
    set_state(INACTIVE)
    vignette.queue_free()


func _submit_response():
    response_construction_timer.cancel()
    var response := response_builder.get_response_values()
    response.evaluate(
        stats, negative_response_threshold,
        positive_response_threshold
    )
    var response_text := (
        response_narration_set
        .build_response_text(response, stats)
    )
    stats.update_values(response)
    _update_stat_meters(response, true)
    if stats.is_full || stats.failed: return

    view.display_constructed_response(response_text)
    state = RESPONSE_DISPLAY
    TweenHelpers.call_delayed_realtime(
        func():
        set_state(QUOTE_DISPLAY)
        view.display_npc_quote(
            npc_dialogue_set.get_quote_for_response(response)
        )
        , duration_response_display
    )
