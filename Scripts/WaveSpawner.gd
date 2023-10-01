extends Node2D

class_name WaveSpawner

@export var enemy:PackedScene
@export var enemyOrigin:Node2D
@export var finalPos:Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	SpawnWave()



func SpawnWave():
	var currentRound = Globals.currentRound
	var spawnAmount = 1

	if currentRound > 1:
		spawnAmount = clampi(currentRound + 1, spawnAmount, 6)

	var spawnPos = finalPos.global_position

	for i in range(0, spawnAmount):
		var spawnedEnemy = enemy.instantiate() as Enemy
		spawnedEnemy.global_position = enemyOrigin.global_position  # Set the position directly
		get_parent().call_deferred("add_child", spawnedEnemy)
		Globals.currentEnemies.append(spawnedEnemy)

		# Tween the enemies into position so it looks like they run in
		spawnPos.x -= 40
		var moveEnemyTween = get_tree().create_tween()
		moveEnemyTween.tween_property(spawnedEnemy, "global_position", spawnPos, 1).set_trans(Tween.TRANS_SINE)

		# Do a check if we are on the final enemy moving into position so we can do a callback to start the round
		if i == spawnAmount - 1:
			moveEnemyTween.finished.connect(FinishedSpawning)

func FinishedSpawning():
	var turnController = get_parent().get_node("TurnController") as TurnController
	turnController.RoundTimer.start()

	
