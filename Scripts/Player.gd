extends Node2D

class_name Player

var Health:int
var HitChance:float
var Damage:float
var RoundHealing:int
var CritChance:float
var CritIncrease:float
var Armor:int
var Turns:int

var defaultHealth:int = 3
var defaultHitChance:float = 100
var defaultDamage:float = 2
var defaultRoundHealing:int = 1
var defaultCritChance:float = 5
var defaultCritIncrease:float = 5
var defaultArmor:int = 0
var defaultTurns:int = 2

var playerMovebackTween:Tween
var currentEnemy:Enemy
var ogPos:Vector2
var attackIndex:int = 0


signal on_health_changed(current_health : int)
signal on_stats_changed(player:Player)
# Called when the node enters the scene tree for the first time.
func _ready():

	
	ResetStats()
	emit_signal("on_health_changed",Health)
	emit_signal("on_stats_changed",self)
	ogPos = self.global_position




func Attack():
	var attackTween = get_tree().create_tween()
	var randNumber = randf_range(0,100)
	attackIndex += 1
	if HitChance >= randNumber:
		#Get all the current enemies and then find the enemy in front and damage it
		var enemies = Globals.currentEnemies

		#No enemies are left set turns to max so we dont loop back into attack and move to origin 
		var frontIndex = enemies.size() -1



		currentEnemy = enemies[frontIndex]
		var finalLoc = currentEnemy.global_position
		finalLoc.x -= 30
		
		
		#Move to the EnemyLocation
		attackTween.tween_property(self,"global_position",finalLoc,.5).set_trans(Tween.TRANS_SINE)
		attackTween.tween_property(self,"rotation_degrees",-60,.65).set_trans(Tween.TRANS_SINE)
		attackTween.tween_property(self,"rotation_degrees",+40,.20).set_trans(Tween.TRANS_SINE)
		attackTween.tween_property(self,"rotation_degrees",0,.35).set_trans(Tween.TRANS_SINE)
		attackTween.tween_callback(DamageCurrentEnemy)
		attackTween.finished.connect(MoveBackToOrigin)
		print("Attacking Enemy Idex " + str(frontIndex))
	else:
		MoveBackToOrigin()

func RoundEndPlayer():
	attackIndex = Turns
	
	#find the center of the scene but only the X and use the player Y
	# Calculate the center point
	var turnController = get_parent().get_node("TurnController") as TurnController
	var finalPos = turnController.centerPos.global_position
	finalPos.y = global_position.y
	
	var moveTween = get_tree().create_tween()
	moveTween.tween_property(self,"global_position",finalPos,.5).set_trans(Tween.TRANS_SINE)
	
	turnController.RoundTimer.stop()
	turnController.EndRound()






func MoveBackToOrigin():
	print("Hello testing from Cllabck")

	if(attackIndex != Turns):
		Attack()
		return;


	attackIndex = 0
	var turnController = get_parent().get_node("TurnController") as TurnController
	var moveBackTween = get_tree().create_tween()
	moveBackTween.tween_property(self,"global_position",ogPos,.5).set_trans(Tween.TRANS_SINE)
	moveBackTween.finished.connect(turnController.StartRoundTimer)
	
func DamageCurrentEnemy():
	print("Taking Damage")
	if currentEnemy != null:
		currentEnemy.TakeDamage(2)
		if(Globals.currentEnemies.size() <= 0 ):
			RoundEndPlayer()


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
	Turns = defaultTurns

func UpdateStats(inItem:Item,bIncrease:bool):

	if bIncrease:
		Damage += IncreasePercentage(Damage,inItem.damage)
		HitChance += IncreasePercentage(HitChance,inItem.hitChance)
		CritChance += IncreasePercentage(CritChance,inItem.critChance)
		CritIncrease += IncreasePercentage(CritIncrease,inItem.critIncrease)
		Armor += inItem.armor
		Turns += inItem.turns	
		IncreasePlayerHealth(inItem.increaseHealth)
	else:
		Damage -= IncreasePercentage(Damage,inItem.damage)
		HitChance -= IncreasePercentage(HitChance,inItem.hitChance)
		CritChance -= IncreasePercentage(CritChance,inItem.critChance)
		CritIncrease -= IncreasePercentage(CritIncrease,inItem.critIncrease)
		Armor -= inItem.armor
		Health -= inItem.increaseHealth
		Turns += inItem.turns	
		emit_signal("on_health_changed",Health)

	emit_signal("on_stats_changed",self)

func IncreasePercentage(baseAmount:float,Percentage:float) ->float:	
	return round((Percentage / 100) * baseAmount)

	
