extends Node


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_APPLICATION_FOCUS_IN:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        NOTIFICATION_APPLICATION_FOCUS_OUT:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        
func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("pause"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE