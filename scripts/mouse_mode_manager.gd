class_name MouseModeManager
extends Node

static var capturing_disabled: bool


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_APPLICATION_FOCUS_IN: capture_mouse()
        NOTIFICATION_APPLICATION_FOCUS_OUT: release_mouse()

func _ready() -> void:
    GameModeSignalBus.conversation_started.connect(
        release_and_disable_capturing
    )
    GameModeSignalBus.conversation_ended.connect(
        capture_and_enable_capturing
    )

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton: capture_mouse()

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("pause"): release_mouse()


static func capture_and_enable_capturing():
    capturing_disabled = false
    capture_mouse()

static func release_and_disable_capturing():
    capturing_disabled = true
    release_mouse()


static func capture_mouse():
    if capturing_disabled: return
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

static func release_mouse():
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
