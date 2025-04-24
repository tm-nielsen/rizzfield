class_name ResponseFragment
extends Resource

@export var name: String
@export var value: int = 1
@export var shape_texture: Texture2D

var cells: Array[Vector2i]
var size: Vector2i


func initialize():
    var shape_image = shape_texture.get_image()
    size = shape_image.get_size()
    generate_cells(shape_image)

func generate_cells(shape_image: Image):
    cells = []
    for x in size.x: for y in size.y:
        if shape_image.get_pixel(x, y).v > 0.5:
            cells.append(Vector2i(x, y))


func get_origin_cell_centre() -> Vector2:
    return (Vector2.ONE - Vector2(size)) / 2.0
