extends CharacterBody3D

@export var vignette_prefab: PackedScene
@export var combat_prefab: PackedScene
@export var head_node: BoneAttachment3D

@export_subgroup("parameters")
@export_range(0, 180) var view_range: float = 60
@export var activation_time: float = 1 / 12.0
@export_flags_3d_physics var raycast_mask = 3

var camera: Camera3D
var triggered: bool = false


func _ready() -> void:
    head_node.visible = false;
    head_node.override_pose = false;
    camera = get_viewport().get_camera_3d()

func _physics_process(_delta: float) -> void:
    if check_angle() && check_raycast():
        activate()

    velocity += get_gravity()
    move_and_slide()


func check_angle() -> bool:
    var diff = camera.global_position - head_node.global_position
    return diff.angle_to(-head_node.basis.z) < deg_to_rad(view_range)

func check_raycast() -> bool:
    var space_state := get_world_3d().direct_space_state
    var result := space_state.intersect_ray(
        PhysicsRayQueryParameters3D.create(
        head_node.global_position,
        camera.global_position,
        raycast_mask)
    )
    return result != {} && result.collider is PlayerController


func activate():
    triggered = true
    head_node.visible = true
    head_node.override_pose = true
    head_node.look_at(camera.global_position)
    camera.look_at(head_node.global_position)

    (func(): get_tree().paused = true).call_deferred()
    TweenHelpers.call_delayed_realtime(start_conversation, activation_time)

func start_conversation():
    var vignette_instance: Node3D = vignette_prefab.instantiate()
    vignette_instance.global_transform = global_transform
    GameModeSignalBus.combat_triggered.connect(spawn_combat_instance)
    GameModeSignalBus.notify_conversation_triggered(vignette_instance)

func spawn_combat_instance():
    var combat_instance: Node3D = combat_prefab.instantiate()
    add_sibling(combat_instance)
    combat_instance.transform = transform
    queue_free()
