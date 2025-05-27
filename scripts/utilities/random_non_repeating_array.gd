class_name RandomNonRepeatingArray

var _entries: Array[Variant]
var _selection_queue: Array[Variant]


func _init(p_entries: Array[Variant]):
    _entries = p_entries.duplicate()
    _selection_queue = p_entries.duplicate()
    _selection_queue.shuffle()


func pick_new() -> Variant:
    if _selection_queue.size() == 0:
        push_warning("Random Non Repeating Array has no _entries to select from")
        return ""

    var selected_entry = _selection_queue.pop_back()
    if _selection_queue.is_empty():
        _selection_queue = _entries.duplicate()
        _selection_queue.shuffle()

    return selected_entry


func append(new_entry: Variant) -> void:
    _entries.append(new_entry)
    _selection_queue.append(new_entry)
    _selection_queue.shuffle()
