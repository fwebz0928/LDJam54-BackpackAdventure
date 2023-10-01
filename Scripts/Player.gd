extends Node2D

class_name Player

var Health:int
var HitChance:float
var Damage:float
var RoundHealing:int
var CritChance:float
var CritIncrease:float
var Armor:int

var defaultHealth:int = 3
var defaultHitChance:float = 45
var defaultDamage:float = 25
var defaultRoundHealing:int = 1
var defaultCritChance:float = 5
var defaultCritIncrease:float = 5
var defaultArmor:int = 0

signal on_health_changed(current_health : int)
signal on_stats_changed(player:Player)
# Called when the node enters the scene tree for the first time.
func _ready():

	
	ResetStats()
	print("This is player")
	emit_signal("on_health_changed",Health)
	emit_signal("on_stats_changed",self)



func Attack():

	var randNumber = randf_range(0,100)
	if HitChance >= randNumber:
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
	emit_signal("on_health_changed",Health)

func IncreaseDefaultHealth(amount:int):
	defaultHealth += amount

func HasHealth()->bool:
	return Health>0

func ResetStats():
	Health = defaultHealth
	Damage = defaultDamage
	HitChance = defaultHitChance
	RoundHealing = defaultRoundHealing
	CritIncrease = defaultCritIncrease
	CritChance = defaultCritChance
	Armor = defaultArmor

func UpdateStats(inItem:Item,bIncrease:bool):

	if bIncrease:
		Damage += IncreasePercentage(Damage,inItem.damage)
		HitChance += IncreasePercentage(HitChance,inItem.hitChance)
		CritChance += IncreasePercentage(CritChance,inItem.critChance)
		CritIncrease += IncreasePercentage(CritIncrease,inItem.critIncrease)
		Armor += inItem.armor
		IncreasePlayerHealth(inItem.increaseHealth)
	else:
		Damage -= IncreasePercentage(Damage,inItem.damage)
		HitChance -= IncreasePercentage(HitChance,inItem.hitChance)
		CritChance -= IncreasePercentage(CritChance,inItem.critChance)
		CritIncrease -= IncreasePercentage(CritIncrease,inItem.critIncrease)
		Armor -= inItem.armor
		Health -= 1
		emit_signal("on_health_changed",Health)

	emit_signal("on_stats_changed",self)







func IncreasePercentage(baseAmount:float,Percentage:float) ->float:	
	return round((Percentage / 100) * baseAmount)

	
