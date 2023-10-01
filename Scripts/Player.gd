extends Node2D

class_name Player

var Health:int
var HitChance:float
var Damage:float
var RoundHealing:int

var defaultHealth:int = 3
var defaultHitChance:float = 40
var defaultDamage:float = 25
var defaultRoundHealing:int = 1


signal on_health_changed(current_health : int)

# Called when the node enters the scene tree for the first time.
func _ready():

	ResetStats()
	emit_signal("on_health_changed",Health)



func Attack():

	var randNumber = randf_range(0,100)
	if HitChance>= randNumber:
		#Get all the current enemies and then find the enemy in front and damage it
		var enemies = Globals.currentEnemies
		var frontIndex = enemies.size() -1
		var currentEnemy = enemies[frontIndex]
		if currentEnemy != null:
			currentEnemy.TakeDamage(Damage)


func UpdateHealth(amount:int):
	Health -= amount
	emit_signal("on_health_changed",Health)
	if(Health <= 0):
		var TurnController = get_parent().get_node("TurnController") as TurnController
		TurnController.EndRound()
		#Do player death things

func IncreasePlayerHealth(amount:int):
	Health += amount


func HasHealth()->bool:
	return Health>0

func ResetStats():
	Damage = defaultDamage
	HitChance = defaultHitChance
	RoundHealing = defaultRoundHealing