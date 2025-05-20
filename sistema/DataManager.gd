class_name DataManager extends Node

const version = "1.0"
var runtime_storage = {}
var environment:Level = null
var player:Player = null
var current_scene = "interface/carregando.tscn"
var config = {
	"initial":true,
	"sound": {
		"global":10,
		"sfx":10,
		"bgm":75
	},
	"difficulty": {
		"autosave":true,
		"hardcore":false
	}
}

func sync_config():
	var ini = ConfigFile.new()
	if config.initial:
		if not ini.load("user://config.ini") == OK:
			config.initial=false
			sync_config()
			return
		for section in config.keys():
			if ini.has_section(section):
				for key in config[section].keys():
					if ini.has_section_key(section,key):
						config[section][key]=ini.get_value(section,key)
		config.initial=false
		sync_config()
	else:
		for section in config.keys(): for key in config[section].keys():
			ini.set_value(section,key,config[section][key])	
	config.initial=false

func save():
	pass

func load():
	pass

class PlayerSaveInfo:
	var lifepoints:int
	var manapoints:int
	var staminapoints:int
	var position:Vector2
	var supermode:bool
	func _init(player:Player):
		lifepoints = player.lifepoints
		manapoints = player.manapoints
		staminapoints = player.staminapoints
		position = player.position
		supermode = player.supermode

class EnemySaveInfo:
	var lifepoints:int
	var manapoints:int
	var position:Vector2
	var velocity:Vector2
	func _init(ememy:BaseEnemy):
		pass

class ParticleSaveInfo:
	var playerdamage:bool
	var position:Vector2
	var velocity:Vector2

class SaveData:
	var player:PlayerSaveInfo
	var enemies:Array[EnemySaveInfo]
	var particles:Array[ParticleSaveInfo]
