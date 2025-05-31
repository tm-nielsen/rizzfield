extends Node

signal npc_spoke
signal response_construction_started

func notify_npc_spoke():
    npc_spoke.emit()

func notify_response_construction_started():
    response_construction_started.emit()
