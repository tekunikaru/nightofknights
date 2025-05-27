extends Control

func _ready():
	$Name.text = get_parent().name
	$LifeBar.set_value(get_parent().lifepoints)
	get_parent().hit.connect(func(_d):$LifeBar.set_value(get_parent().lifepoints))
	get_parent().aggro.connect(func(state):visible=state)

func _process(_delta):
	$Coords.text = str(get_parent().position)
