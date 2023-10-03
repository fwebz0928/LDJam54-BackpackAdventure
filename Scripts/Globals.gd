extends Node

var currentRound: int = 2
var currentEnemies:Array


func UpdatedCurrentRound():
	currentRound += 1

func RemoveEnemy(enemyToRemove:Enemy) ->int:
	var index = currentEnemies.find(enemyToRemove)
	if(index != -1):
		currentEnemies.remove_at(index)
		print("Removing Enemy")
	return currentEnemies.size()

