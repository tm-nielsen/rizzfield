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

@export_subgroup("timing", "duration")
@export var duration_prompt_display: float = 3
@export var duration_response_construction: float = 8
@export var duration_response_display: float = 2
@export var duration_quote_display: float = 2

var state: ConversationState
var vignette: Node3D
var dialogue: ConversationDefinition.Dialogue
var stats: Array[ConversationStatDefinition.ConversationStat]


func _ready() -> void:
    GameModeSignalBus.conversation_triggered.connect(_on_conversation_started)
    response_construction_timer.timeout.connect(_submit_response)
    hide()

func _process(_delta: float) -> void:
    if visible && Input.is_key_pressed(KEY_SPACE):
        vignette.queue_free()
        get_tree().paused = false
        hide()
        GameModeSignalBus.combat_triggered.emit()
    if Input.is_key_pressed(KEY_R):
        get_tree().paused = false
        get_tree().reload_current_scene()


func set_state(new_state: ConversationState):
    state = new_state
    match state:
        INACTIVE: hide()
        PROMPT_DISPLAY:
            view.start_prompt_display()
            set_state_in(RESPONSE_CONSTRUCTION, duration_prompt_display)
            show()
        RESPONSE_CONSTRUCTION:
            view.start_response_construction()
            response_construction_timer.start(duration_response_construction)

func set_state_in(target_state: ConversationState, delay: float):
    TweenHelpers.call_delayed_realtime(
        set_state.bind(target_state), delay
    )


func _on_conversation_started(
    definition: ConversationDefinition,
    vignette_instance: Node3D
):
    dialogue = definition.dialogue
    stats.assign(definition.stats.map(
        ConversationStatDefinition.ConversationStat.new
    ))
    vignette = vignette_instance
    vignette_viewport.add_child(vignette)
    set_state(PROMPT_DISPLAY)

func _submit_response():
    response_construction_timer.cancel()
    view.display_constructed_response("response narration")
    state = RESPONSE_DISPLAY
    var delay_tween = TweenHelpers.call_delayed_realtime(
        func():
        state = QUOTE_DISPLAY
        view.display_npc_quote(dialogue.neutral_quotes.pick_random())
        , duration_response_display
    )
    delay_tween.tween_interval(duration_quote_display)
    delay_tween.tween_callback(set_state.bind(RESPONSE_CONSTRUCTION))
