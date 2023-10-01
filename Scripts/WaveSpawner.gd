extends Node2D

@export var enemy:PackedScene
@export var spawnPoint:Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	SpawnWave()



func SpawnWave():
	var currentRound = Globals.currentRound
	var spawnAmount = 1

	if currentRound > 1:
		spawnAmount = currentRound + 1

	var spawnPos = spawnPoint.global_position

	for i in range(0,spawnAmount) :
		var spawnedEnemy = enemy.instantiate() as Enemy
		spawnPos.x -= 40
		spawnedEnemy.position = spawnPos
		get_parent().call_deferred("add_child", spawnedEnemy)
		Globals.currentEnemies.append(spawnedEnemy)






