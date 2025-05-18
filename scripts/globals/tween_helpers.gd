extends Node


func build_tween(
    bound_node: Node,
    delay: float = 0,
    easing := Tween.EASE_OUT,
    transition := Tween.TRANS_BACK
) -> Tween: 
    var tween := create_tween()
    tween.bind_node(bound_node)
    tween.set_ease(easing)
    tween.set_trans(transition)
    tween.tween_interval(delay)
    return tween


func call_delayed(callback: Callable, delay: float) -> Tween:
    var delay_tween = create_tween()
    delay_tween.tween_interval(delay)
    delay_tween.tween_callback(callback)
    return delay_tween

func call_delayed_realtime(callback: Callable, delay: float) -> Tween:
    var delay_tween = call_delayed(callback, delay)
    delay_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    return delay_tween