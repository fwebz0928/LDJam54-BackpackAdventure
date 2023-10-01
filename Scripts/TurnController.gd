extends Node2D

class_name TurnController

@onready var ItemScene:PackedScene = preload("res://Scenes/item.tscn")

@export var itemSpawnOrigin:Node2D
@export var player:Player
@export var playerOriginPoint:Node2D
@export var leftSideSpawn:Node2D
@export var rightSideSpawn:Node2D
var isPlayerTurn:bool = true
var bRoundOver:bool = false
var RoundTimer:Timer

var Enemies:Array
var inventoryUI:Inventory
var gameUI:GameUI

# Called when the node enters the scene tree for the first time.
func _ready():

	#get the player inventory and disable it
	inventoryUI = get_parent().get_node("Inventory") as Inventory
	gameUI = get_parent().get_node("GameUI") as GameUI
	inventoryUI.visible = false
	inventoryUI.set_process(false)
	gameUI.visible = true

	var tween = get_tree().create_tween()
	player.global_position = playerOriginPoint.global_position
	var destination = player.global_position
	destination.x += 130
	tween.tween_property(player,"global_position",destination,1).set_trans(Tween.TRANS_SINE)
	


	#Setup the round timer so not doing attacks one after the other instanttly
	RoundTimer = Timer.new()
	RoundTimer.wait_time = 3
	RoundTimer.one_shot = true
	RoundTimer.timeout.connect(StartRound)
	add_child(RoundTimer)

	#Get a refernce to all the enemies in the current Round
	Enemies = Globals.currentEnemies

	#Start the actual round
	#StartRound()

func StartRound():

	if bRoundOver == true:
		RoundTimer.stop()
		return

	#Check whos turn it is
	if isPlayerTurn:
		PlayerAttack()
	else :
		EnemyAttack()

func EndRound():
	bRoundOver= true
	RoundTimer.stop()
	
	#Move the player to the center of the scene
	var tween = get_tree().create_tween()
	var destination = player.global_position
	destination.x += 50
	tween.tween_property(player,"global_position",destination,1).set_trans(Tween.TRANS_SINE)

	StartLootMode()

func StartNewRound():
	
	#Do a screen fade transition effect

	#Move player off screen so we can move it later to make it look like runs in
	player.global_position = playerOriginPoint.global_position

	#Disable the Inventory UI and update the Game UI
	gameUI.visible = true
	inventoryUI.visible = false
	inventoryUI.set_process(false)

	#Move the player from offscreen back to the fight pos
	var movePos = playerOriginPoint.global_position
	movePos.x += 130
	var playerMoveTween = get_tree().create_tween()
	playerMoveTween.tween_property(player,"global_position",movePos,1).set_trans(Tween.TRANS_SINE)

	
	#Update the rounds and spawn a new wave of enemies
	Globals.currentRound += 1
	var waveSpawner = get_parent().get_node("WaveSpawner") as WaveSpawner
	waveSpawner.SpawnWave()




func PlayerAttack():
	isPlayerTurn = false
	player.Attack()
	if bRoundOver == false:
		RoundTimer.wait_time = .5
		RoundTimer.start()

func EnemyAttack():
	isPlayerTurn =  true
	print("Enemies Attacking")
	if bRoundOver == false:
		RoundTimer.start()

func StartLootMode():

	#Enable the Inventory UI and disable the Game UI
	inventoryUI.visible = true
	inventoryUI.set_process(true)
	gameUI.visible = false


	#spawn the Left side items
	SpawnItems(leftSideSpawn.global_position,2)
	#spawn the right side items
	SpawnItems(rightSideSpawn.global_position,2)

func SpawnItems(spawnPoint:Vector2,spawnAmount:int):

	# Generate a bunch of random items that the player can use
	for i in range(0,spawnAmount):
		var itemMoveTween = get_tree().create_tween()
		var newItem = ItemScene.instantiate() as Item
		newItem.global_position = itemSpawnOrigin.global_position
		var randNum = randi_range(1,7)
		newItem.LoadItem(randNum)
		newItem.selected = false
		spawnPoint.y -= 120
		itemMoveTween.tween_property(newItem,"global_position",spawnPoint,.5).set_trans(Tween.TRANS_SINE)
		call_deferred("add_child",newItem)
		

	
