extends Node2D

class_name Enemy

var enemyHealth:int = 2
var ogSpot:Vector2
var player:Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("Player") as Player



func Attack():
	var randNumber = randf_range(0,100)
	var attackTween = get_tree().create_tween()
	ogSpot = global_position
	if(100>= randNumber):
		player = get_parent().get_node("Player") as Player
		var finalLoc = player.global_position
		finalLoc.x += 50
		print(finalLoc)

		attackTween.finished.connect(DamagePlayer)

		attackTween.tween_property(self,"global_position",finalLoc,.5).set_trans(Tween.TRANS_SINE)
		attackTween.tween_property(self,"rotation_degrees",+60,.55).set_trans(Tween.TRANS_SINE)
		attackTween.tween_property(self,"rotation_degrees",-40,.20).set_trans(Tween.TRANS_SINE)
		attackTween.tween_property(self,"rotation_degrees",0,.35).set_trans(Tween.TRANS_SINE)
		attackTween.tween_callback(MoveBackToSpot)
	else:
		MoveBackToSpot()

func DamagePlayer():
	player.UpdateHealth(1)

func MoveBackToSpot():
	var turnController = get_parent().get_node("TurnController") as TurnController
	var moveBackTween = get_tree().create_tween()
	moveBackTween.tween_property(self,"global_position",ogSpot,.5).set_trans(Tween.TRANS_SINE)
	moveBackTween.finished.connect(turnController.StartRoundTimer)
	pass

func TakeDamage(damageAmount:int):
	enemyHealth -= damageAmount
	if enemyHealth <= 0:
		#Check if this is the final enemy in the array
		print("Killed Enemy")
		var amount = Globals.RemoveEnemy(self)
		if(amount <= 0):
			var turnController = get_parent().get_node("TurnController") as TurnController
			turnController.RoundTimer.stop()
			turnController.EndRound()
		
		#remove the enemy
		queue_free()