class_name RandomNonRepeatingArray

var _entries: Array[Variant]
var _unused_entries: Array[Variant]


func _init(p_entries: Array[Variant]):
    _entries = p_entries.duplicate()
    _unused_entries = p_entries.duplicate()


func pick_new() -> Variant:
    if _unused_entries.size() == 0:
        push_warning("Random Non Repeating Array has no _entries to select from")
        return ""

    var selected_entry = _unused_entries.pick_random()
    _unused_entries.erase(selected_entry)
    if _unused_entries.is_empty():
        _unused_entries = _entries.duplicate()

    return selected_entry


func append(new_entry: Variant) -> void:
    _entries.append(new_entry)
    _unused_entries.append(new_entry)
