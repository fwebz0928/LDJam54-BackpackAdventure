extends Node2D

class_name Enemy

var enemyHealth:int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func Attack():
	print("Attacking Player")

func TakeDamage(damageAmount:int):
	enemyHealth -= damageAmount
	if enemyHealth <= 0:
		#Check if this is the final enemy in the array
		var amount = Globals.RemoveEnemy(self)
		if(amount <= 0):
			var turnController = get_parent().get_node("TurnController") as TurnController
			turnController.RoundTimer.stop()
			turnController.EndRound()
		
		#remove the enemy
		queue_free()