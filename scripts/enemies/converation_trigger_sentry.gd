extends Node3D

@export var vignette_prefab: PackedScene
@export var combat_prefab: PackedScene

@export_subgroup("node references")
@export var head_node: BoneAttachment3D
@export var raycast: RayCast3D

@export_subgroup("parameters")
@export_range(0, 180) var view_range = 60
@export var activation_time: float = 1 / 12.0

var camera: Camera3D
var triggered: bool = false


func _ready() -> void:
    head_node.visible = false;
    head_node.override_pose = false;
    camera = get_viewport().get_camera_3d()

func _process(_delta: float) -> void:
    if raycast.is_colliding():
        activate()
    else:
        raycast.target_position = camera.global_position - raycast.global_position


func activate():
    triggered = true
    head_node.visible = true
    head_node.override_pose = true
    head_node.look_at(camera.global_position)
    camera.look_at(head_node.global_position)

    get_tree().paused = true;
    var end_tween = create_tween()
    end_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    end_tween.tween_interval(activation_time)
    end_tween.tween_callback(start_conversation)

func start_conversation():
    var vignette_instance: Node3D = vignette_prefab.instantiate()
    vignette_instance.global_transform = global_transform
    # GameModeSignalBus.notify_conversation_triggered(vignette_instance)

    var combat_instance: Node3D = combat_prefab.instantiate()
    add_sibling(combat_instance)
    combat_instance.transform = transform
