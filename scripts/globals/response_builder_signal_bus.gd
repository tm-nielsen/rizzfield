extends Node

signal mouse_entered_fragment_body(fragment: ResponseFragment)
signal mouse_exited_fragment_body(fragment: ResponseFragment)
signal fragment_body_grabbed(fragment: ResponseFragment)
signal fragment_body_dropped(fragment: ResponseFragment)


func notify_fragment_hovered(fragment: ResponseFragment):
    mouse_entered_fragment_body.emit(fragment)

func notify_fragment_hover_ended(fragment: ResponseFragment):
    mouse_exited_fragment_body.emit(fragment)

func notify_fragment_grabbed(fragment: ResponseFragment):
    fragment_body_grabbed.emit(fragment)

func notify_fragment_dropped(fragment: ResponseFragment):
    fragment_body_dropped.emit(fragment)
