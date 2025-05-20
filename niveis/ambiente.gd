class_name Level extends Node2D

@export var gravity:float = 30

func _ready() -> void:
	DataManagerInstance.runtime_storage.set("Level",self)
