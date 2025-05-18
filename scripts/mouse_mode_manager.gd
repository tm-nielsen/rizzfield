extends Node

var capturing_disabled: bool


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_APPLICATION_FOCUS_IN: capture_mouse()
        NOTIFICATION_APPLICATION_FOCUS_OUT: release_mouse()

func _ready() -> void:
    GameModeSignalBus.conversation_started.connect(
        func(): capturing_disabled = true; release_mouse()
    )
    GameModeSignalBus.conversation_ended.connect(
        func(): capturing_disabled = false; capture_mouse()
    )

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton: capture_mouse()

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("pause"): release_mouse()


func capture_mouse():
    if capturing_disabled: return
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func release_mouse():
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
