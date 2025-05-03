class_name PlacedResponseFragment

var body: ResponseFragmentBody
var fragment: ResponseFragment
var origin: Vector2i

var shape_image: Image
var cells: Array[Vector2i]
var size: Vector2i


func _init(
    fragment_body: ResponseFragmentBody
) -> void:
    body = fragment_body
    fragment = fragment_body.fragment
    shape_image = fragment.shape_texture.get_image()
    _generate_shape()
    origin = Vector2i.ZERO

func _generate_shape():
    size = shape_image.get_size()
    cells = []
    for x in size.x: for y in size.y:
        if shape_image.get_pixel(x, y).v > 0.5:
            cells.append(Vector2i(x, y))


func rotate(direction: ClockDirection):
    shape_image.rotate_90(direction)
    _generate_shape()
    body.rotate_placement(
        PI / 2 * (-1 if direction == CLOCKWISE else 1)
    )


func for_each_cell(method: Callable):
    for cell_offset in cells:
        method.call(origin + cell_offset)

func occupies_cell(cell_coords: Vector2i) -> bool:
    return !for_all_cells(
        func(cell: Vector2i):
            return cell != cell_coords
    )

func for_all_cells(predicate: Callable) -> bool:
    for cell_offset in cells:
        if !predicate.call(origin + cell_offset):
            return false
    return true

func for_no_cells(predicate: Callable) -> bool:
    for cell_offset in cells:
        if predicate.call(origin + cell_offset):
            return false
    return true


func has_different_body(
    placed_fragment: PlacedResponseFragment
) -> bool:
    return body != placed_fragment.body

func get_origin_cell_centre() -> Vector2:
    return (Vector2.ONE - Vector2(size)) / 2.0
