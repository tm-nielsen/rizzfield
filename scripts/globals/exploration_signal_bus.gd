extends Node

signal fragment_collected(fragment: ResponseFragment)
signal fragment_discovered(title: String, description: String)


func notify_fragment_collected(
    fragment: ResponseFragment,
    title: String, description: String
):
    fragment_collected.emit(fragment)
    fragment_discovered.emit(title, description)