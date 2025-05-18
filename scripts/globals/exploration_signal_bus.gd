extends Node

signal fragment_collected(fragment: ResponseFragment)


func notify_fragment_collected(fragment: ResponseFragment):
    fragment_collected.emit(fragment)