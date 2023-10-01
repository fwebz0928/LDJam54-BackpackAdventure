extends Node2D

class_name TurnController

@onready var ItemScene:PackedScene = preload("res://Scenes/item.tscn")

@export var player:Player
var isPlayerTurn:bool = true
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
	gameUI.visible = true


	#Setup the round timer so not doing attacks one after the other instanttly
	RoundTimer = Timer.new()
	RoundTimer.wait_time = 2
	RoundTimer.one_shot = true
	RoundTimer.timeout.connect(StartLootMode)
	add_child(RoundTimer)
	#RoundTimer.start()

	#Get a refernce to all the enemies in the current Round
	Enemies = Globals.currentEnemies

	#Start the actual round
	#StartRound()

func StartRound():

	if isPlayerTurn:
		PlayerAttack()
	else :
		EnemyAttack()



func EndRound():
	RoundTimer.stop()
	get_tree().quit()

func PlayerAttack():
	isPlayerTurn = false
	player.Attack()
	RoundTimer.start()


func EnemyAttack():
	isPlayerTurn =  true
	print("Enemies Attacking")
	RoundTimer.start()
	pass

func StartLootMode():

	#Enable the Inventory UI and disable the Game UI
	inventoryUI.visible = true
	gameUI.visible = false


	var spawnedItem = ItemScene.instantiate() as Item
	add_child(spawnedItem)
	spawnedItem.LoadItem(1)
	spawnedItem.selected = true
	inventoryUI.itemHeld = spawnedItem
	spawnedItem.global_position = get_global_mouse_position()


	# Generate a bunch of random items that the player can use
	var randPoint = player.global_position
	randPoint.x -= 50

	#spawn the Left side items
	for i in range(0,3):
		var newItem = ItemScene.instantiate() as Item
		var randNum = randi_range(1,7)
		newItem.LoadItem(randNum)
		newItem.selected = false
		randPoint.y -= 100
		newItem.position = randPoint
		call_deferred("add_child",newItem)

	#spawn the right side items



	
