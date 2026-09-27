class_name PlayerInput
extends RefCounted
## Human input: reads one specific device (keyboard layout or joypad).

var device: int


func _init(dev: int) -> void:
	device = dev


func sample(_fighter: Fighter) -> int:
	return Controls.read(device)


func is_human() -> bool:
	return true
