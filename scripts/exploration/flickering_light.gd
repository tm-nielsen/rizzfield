extends OmniLight3D

@export var base_energy: float = 1
@export var volume_energy_multiplier: float = 10000000
@export var bus_name: StringName = "Flickering Lights"

var analyser: AudioEffectSpectrumAnalyzerInstance

func _ready() -> void:
    var bus_index := AudioServer.get_bus_index(bus_name)
    analyser = AudioServer.get_bus_effect_instance(bus_index, 0)

func _process(_delta: float) -> void:
    var light_volume = (
        analyser.get_magnitude_for_frequency_range
        (500, 1000, analyser.MAGNITUDE_AVERAGE)
        .length_squared()
    )
    light_energy = (
        base_energy +
        light_volume * volume_energy_multiplier
    )
