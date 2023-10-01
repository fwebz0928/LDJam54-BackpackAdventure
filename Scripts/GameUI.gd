extends CanvasLayer

class_name GameUI


@export var HeartContainer:PackedScene
@export var HeartBox:HBoxContainer

var player:Player

func _ready():
	player = get_parent().get_node("Player") as Player
	player.on_health_changed.connect(UpdateHealth)


func UpdateHealth(InHealth:int):
	#Remove all the old hearts so we can add the new ones with correct amount
	var childrenHeart = HeartBox.get_children()
	for heart in childrenHeart:
		heart.queue_free()

	#Add the new hearts to the container
	for i in range(0,InHealth):
		var newHeart = HeartContainer.instantiate()
		HeartBox.add_child(newHeart)


