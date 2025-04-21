extends Node


func call_delayed(callback: Callable, delay: float) -> Tween:
    var delay_tween = create_tween()
    delay_tween.tween_interval(delay)
    delay_tween.tween_callback(callback)
    return delay_tween

func call_delayed_realtime(callback: Callable, delay: float) -> Tween:
    var delay_tween = call_delayed(callback, delay)
    delay_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    return delay_tween