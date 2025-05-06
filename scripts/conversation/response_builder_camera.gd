extends Camera3D

@export var fragment_spawner: ResponseFragmentSpawner

@export_subgroup("placement tween", "placement_tween")
@export var placement_tween_offset: float = 5
@export var placement_tween_on_duration: float = 0.05
@export var placement_tween_off_duration: float = 0.2

var base_fov: float
var placement_tween: Tween


func _ready() -> void:
    base_fov = fov
    fragment_spawner.fragment_spawned.connect(
        func(fragment): fragment.placed.connect(
            start_placement_tween
        )
    )


func start_placement_tween():
    placement_tween = create_tween()
    placement_tween.set_ease(Tween.EASE_OUT)
    placement_tween.set_trans(Tween.TRANS_BACK)
    placement_tween.tween_property(
        self, 'fov', base_fov + placement_tween_offset,
        placement_tween_on_duration
    )
    placement_tween.tween_property(
        self, 'fov', base_fov,
        placement_tween_off_duration
    )
