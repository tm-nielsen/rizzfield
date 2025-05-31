extends DamageableCharacterBody3D

@export var conversation: ConversationDefinition
@export var combat_prefab: PackedScene
@export var head_node: BoneAttachment3D
@export var combat_instance_health: int = 6
@export var pose_name: String = "stand"
@export var animator: AnimationPlayer

@export_subgroup("parameters")
@export_range(0, 180) var view_range: float = 60
@export var view_distance: float = 5
@export var activation_time: float = 1 / 6.0
@export_flags_3d_physics var raycast_mask = 3

var camera: Camera3D
var triggered: bool = false


func _ready() -> void:
    head_node.visible = false;
    head_node.override_pose = false;
    camera = get_viewport().get_camera_3d()
    animator.play(pose_name)
    animator.advance(0)
    animator.process_mode = Node.PROCESS_MODE_ALWAYS
    animator.pause()

func _physics_process(_delta: float) -> void:
    if check_angle() && check_raycast():
        activate()
        return

    velocity += get_gravity()
    move_and_slide()


func check_angle() -> bool:
    var diff = camera.global_position - head_node.global_position
    if diff.length_squared() > view_distance * view_distance: return false
    return diff.angle_to(basis.z) < deg_to_rad(view_range)

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
    if triggered: return
    triggered = true
    animator.play()
    head_node.show()
    head_node.override_pose = true
    head_node.look_at(camera.global_position, Vector3.UP, true)
    camera.look_at(head_node.global_position)
    get_viewport().process_mode = Node.PROCESS_MODE_DISABLED
    TweenHelpers.call_delayed_realtime(start_conversation, activation_time)

func start_conversation():
    var vignette_instance: Node3D = conversation.vignette_prefab.instantiate()
    vignette_instance.global_transform = global_transform
    GameModeSignalBus.combat_triggered.connect(spawn_active_combat_instance)
    GameModeSignalBus.conversation_resolved.connect(spawn_happy_corpse)
    GameModeSignalBus.brick_thrown.connect(spawn_and_damage_combat_instance)
    GameModeSignalBus.notify_conversation_triggered(conversation, vignette_instance)

func replace_with_combat_instance() -> DamageableCharacterBody3D:
    var combat_instance: DamageableCharacterBody3D = combat_prefab.instantiate()
    combat_instance.maximum_health = combat_instance_health
    add_sibling(combat_instance)
    combat_instance.transform = transform
    combat_instance.died.connect(ExitArea.notify_encounter_completed)
    queue_free()
    return combat_instance

func spawn_active_combat_instance():
    var combat_instance = replace_with_combat_instance()
    combat_instance.start_tracking()

func spawn_happy_corpse() -> DamageableCharacterBody3D:
    var combat_instance = replace_with_combat_instance()
    combat_instance.die(Vector3.ZERO)
    combat_instance.smile.show()
    GameModeSignalBus.combat_triggered.disconnect(spawn_active_combat_instance)
    return combat_instance

func spawn_and_damage_combat_instance():
    var combat_instance = replace_with_combat_instance()
    combat_instance.state = STUNNED
    combat_instance.receive_damage(1, Vector3.ZERO)

func receive_damage(_amount: int, _impulse: Vector3):
    var combat_instance = replace_with_combat_instance()
    combat_instance.state = STUNNED
