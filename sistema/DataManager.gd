class_name DataManager extends Node

const version = "1.0"
var runtime_storage = {}
var current_scene = "interface/menu_principal.tscn"
var lifepoints = 10
var manapoints = 10
var staminapoints = 10
var supermode = false
var position = Vector2.ZERO
var autosave = true

func change_level():
	pass

func save_game():
	pass
	
func load_game():
	pass
