class_name PlacedResponseFragment

var body_path: NodePath
var fragment: ResponseFragment
var origin: Vector2i


func _init(
    fragment_body: ResponseFragmentBody
) -> void:
    body_path = fragment_body.get_path()
    fragment = fragment_body.fragment
    origin = Vector2i.ZERO


func for_each_cell(method: Callable):
    for cell_offset in fragment.cells:
        method.call(origin + cell_offset)

func occupies_cell(cell_coords: Vector2i) -> bool:
    return !for_all_cells(
        func(cell: Vector2i):
            return cell != cell_coords
    )

func for_all_cells(predicate: Callable) -> bool:
    for cell_offset in fragment.cells:
        if !predicate.call(origin + cell_offset):
            return false
    return true


func has_different_origin_body(
    placed_fragment: PlacedResponseFragment
) -> bool:
    return body_path != placed_fragment.body_path

func get_origin_cell_centre() -> Vector2:
    return (Vector2.ONE - Vector2(fragment.size)) / 2.0
