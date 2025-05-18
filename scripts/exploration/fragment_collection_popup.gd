extends Control

@export var fragment_mesh: MeshInstance3D
@export var title_label: Label
@export var description_label: Label
@export var close_button: Button

@export_subgroup("tweens")
@export var popup_duration: float = 0.4
@export var close_duration: float = 0.2

@export_subgroup("mesh animation")
@export var frame_timer: FrameTimer
@export var yaw_frequency: float = 1.5
@export var yaw_amplitude: float = PI / 4
@export var pitch_frequency: float = 0.9
@export var pitch_amplitude: float = PI / 8
@export var roll_frequency: float = 0.4
@export var roll_amplitude: float = PI / 20

var size_tween: Tween


func _ready() -> void:
    ExplorationSignalBus.fragment_collected.connect(
        func(fragment: ResponseFragment):
        fragment_mesh.mesh = fragment.mesh
        fragment_mesh.material_override = fragment.create_material()
    )
    ExplorationSignalBus.fragment_discovered.connect(
        func(title: String, description: String):
        title_label.text = title
        description_label.text = description
        popup()
    )
    frame_timer.frame_out.connect(update_mesh_rotation)
    close_button.pressed.connect(close)
    hide()


func popup():
    get_tree().paused = true
    MouseModeManager.release_and_disable_capturing()
    close_button.grab_focus()
    scale = Vector2.ZERO
    if size_tween: size_tween.kill()
    size_tween = TweenHelpers.build_tween(self)
    size_tween.tween_property(
        self, "scale", Vector2.ONE, popup_duration
    )
    show()

func close():
    get_tree().paused = false
    MouseModeManager.capture_and_enable_capturing()
    if size_tween: size_tween.kill()
    size_tween = TweenHelpers.build_tween(
        self, 0, Tween.EASE_OUT, Tween.TRANS_SINE
    )
    size_tween.tween_property(
        self, "scale", Vector2.ZERO, close_duration
    )
    size_tween.tween_callback(hide)


func update_mesh_rotation():
    var time: float = Time.get_ticks_msec() / 1000.0
    fragment_mesh.rotation = Vector3(
        pitch_amplitude * sin(pitch_frequency * time),
        yaw_amplitude * sin(yaw_frequency * time),
        roll_amplitude * sin(roll_frequency * time)
    )
