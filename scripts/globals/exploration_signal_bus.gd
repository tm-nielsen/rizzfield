extends Node

signal fragment_collected(fragment: ResponseFragment)
signal fragment_discovered(title: String, description: String)
signal brick_collected()


func notify_fragment_collected(
    fragment: ResponseFragment, description: String
):
    fragment_collected.emit(fragment)
    fragment_discovered.emit(fragment.title, description)

func notify_brick_collected():
    brick_collected.emit()
