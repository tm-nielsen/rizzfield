extends AnimationPlayer

@export var body_animator: AnimationPlayer
@export var body_animation: String = "stand"

func _ready():
    body_animator.play(body_animation)
    body_animator.advance(10)

    ConversationSignalBus.npc_spoke.connect(
        func():
        play("speak")
        ConversationSignalBus.response_construction_started.connect(
            play.bind("return"),
            CONNECT_ONE_SHOT
        )
    )
