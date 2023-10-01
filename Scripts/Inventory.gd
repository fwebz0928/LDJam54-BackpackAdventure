extends Control

class_name  Inventory


@onready var slotScene =preload("res://Scenes/InventorySlot.tscn")
@onready var inventoryContainer:GridContainer = $"ColorRect/GridContainer"
@onready var inventoryRectangle:ColorRect = $"ColorRect"
@onready var columnCount = inventoryContainer.columns

#Labels for stats
@onready var healthlabel = $"TextureRect/GridContainer/HealthLabel"
@onready var armorLable = $"TextureRect/GridContainer/ArmorLabel"
@onready var hitChance = $"TextureRect/GridContainer/HitChanceLabel"
@onready var damageLabel = $"TextureRect/GridContainer/DamageLabel"
@onready var critChanceLabel = $"TextureRect/GridContainer/CritChanceLabel"
@onready var critLabel = $"TextureRect/GridContainer/CritLabel"


var player:Player
var inventorySlots := []
var itemHeld = null
var currentSlot = null
var canPlace:bool = false
var iconAnchor:Vector2
var itemsInInventory :=[]

# Called when the node enters the scene tree for the first time.
func _ready():

	player = get_parent().get_node("Player") as Player
	player.on_stats_changed.connect(UpdateStatLabels)

	#Generate slots for the Inventory
	for i in range(12):
		CreateSlots()


func _process(delta):

	if inventoryContainer.get_global_rect().has_point(get_global_mouse_position()) == false:
		currentSlot = null


	if itemHeld:
		if Input.is_action_just_pressed("RotateItem"):
			RotateItem()
		if Input.is_action_just_pressed("Place"):
			PlaceItem()
		if Input.is_action_just_pressed("DropItem"):
			DropItem()
	else:
		if Input.is_action_just_pressed("Place"):
			PickupItem()


func CreateSlots():
	var createdSlot = slotScene.instantiate() as InventorySlot
	createdSlot.slotID = inventorySlots.size()
	
	#Add the slot to the grid and the array
	inventoryContainer.add_child(createdSlot)
	inventorySlots.push_back(createdSlot)

	#connect the slots signals for mouse
	createdSlot.slot_entered.connect(OnMouseEntered)
	createdSlot.slot_exited.connect(OnMouseExit)

func OnMouseEntered(inSlot:InventorySlot):
	iconAnchor = Vector2(100000,100000)
	currentSlot = inSlot
	if itemHeld:
		CheckSlotAvailability(inSlot)
		SetGrid.call_deferred(currentSlot)

func OnMouseExit(inSlot:InventorySlot):
	ClearGrid()



func CheckSlotAvailability(inSlot:InventorySlot):
	for grid in itemHeld.itemGrids:
		var gridToCheck = inSlot.slotID + grid[0]+ grid[1] * columnCount
		var lineSwitchCheck = inSlot.slotID % columnCount + grid[0]
		if(lineSwitchCheck < 0 or lineSwitchCheck >= columnCount):
			canPlace = false
			return
		if(gridToCheck < 0 or gridToCheck >= inventorySlots.size()):
			canPlace = false
			return
		if(inventorySlots[gridToCheck].state == inventorySlots[gridToCheck].SlotState.TAKEN):
			canPlace = false
			return

	canPlace = true

func SetGrid(inSlot:InventorySlot):
	for grid in itemHeld.itemGrids:
		var gridToCheck = inSlot.slotID + grid[0]+ grid[1] * columnCount
		var lineSwitchCheck = inSlot.slotID % columnCount + grid[0]
		if(gridToCheck <0 or gridToCheck>= inventorySlots.size()):
			continue
		if(lineSwitchCheck < 0 or lineSwitchCheck >= columnCount):
			continue
		
		if canPlace:
			inventorySlots[gridToCheck].SetColor(inventorySlots[gridToCheck].SlotState.FREE)
			if(grid[1]<iconAnchor.x): iconAnchor.x = grid[1]
			if(grid[0]<iconAnchor.y): iconAnchor.y = grid[0]

		else:
			inventorySlots[gridToCheck].SetColor(inventorySlots[gridToCheck].SlotState.TAKEN)

func ClearGrid():
	for grid in inventorySlots:
		grid.SetColor(grid.SlotState.DEFAULT)

func RotateItem():
	itemHeld.RotateItem()
	ClearGrid()
	if(currentSlot):
		OnMouseEntered(currentSlot)

func PlaceItem():
	if not canPlace or not currentSlot:
		return

	var calculatedGridID = currentSlot.slotID + iconAnchor.x * columnCount + iconAnchor.y
	itemHeld.SnapTo(inventorySlots[calculatedGridID].global_position)

	itemHeld.gridAnchor = currentSlot
	for grid in itemHeld.itemGrids:
		var gridToCheck = currentSlot.slotID + grid[0]+ grid[1] * columnCount
		inventorySlots[gridToCheck].state = inventorySlots[gridToCheck].SlotState.TAKEN
		inventorySlots[gridToCheck].item_stored = itemHeld

	itemsInInventory.push_back(itemHeld)
	player.UpdateStats(itemHeld,true)

	itemHeld = null
	ClearGrid()

func PickupItem():


	#check if above a item 
	if currentSlot == null or  currentSlot.item_stored == null :
		if CheckForItemOutsideBounds() == true :
			return

	if(currentSlot == null or currentSlot.item_stored ==null):
		return

	print("Current Slot Not null")

	itemHeld = currentSlot.item_stored
	
	#check if the item is in the inventory already
	var foundItemIndex = itemsInInventory.find(itemHeld)
	if foundItemIndex != -1:
		itemsInInventory.remove_at(foundItemIndex)

	
	if itemHeld == null:
		return
	itemHeld.selected = true

	for grid in itemHeld.itemGrids:
		var gridToCheck = itemHeld.gridAnchor.slotID + grid[0] + grid[1] * columnCount
		inventorySlots[gridToCheck].state = inventorySlots[gridToCheck].SlotState.FREE
		inventorySlots[gridToCheck].item_stored = null

	#Remove the stats from the player since we pickedup the item
	player.UpdateStats(itemHeld,false)

	CheckSlotAvailability(currentSlot)
	SetGrid.call_deferred(currentSlot)

func GetRandomPosOnBorder() -> Vector2:
	var rectWidth = inventoryRectangle.get_minimum_size().x
	var rectHeight = inventoryRectangle.get_minimum_size().y
	var randPoint = Vector2(0, 0)
	
	while true:
		var angle = randf() * 2 * PI
		var x = rectWidth * 0.5 * cos(angle)
		var y = rectHeight * 0.5 * sin(angle)
		
		randPoint = Vector2(x, y)
		randPoint += inventoryRectangle.get_minimum_size() / 2
		
		if randPoint.length() <= 50:
			break

	return randPoint

func CheckForItemOutsideBounds() -> bool:
	
	if  itemHeld != null:
		return false

	var allItems = get_tree().get_nodes_in_group("Item") 
	for inItem in allItems:
		var itemToCheck = inItem as Item
		if itemToCheck.CheckForPoint():
			itemToCheck.selected= true
			itemHeld = itemToCheck
			ClearGrid()
			return true
	return false

func DropItem():
	if itemHeld == null:
		return

	itemHeld.selected = false;
	itemHeld.global_position = get_global_mouse_position()
	itemHeld = null

func _on_button_pressed():

	#check if the next round is a multiple of 5 and update health
	var nextRoundIndex = Globals.currentRound + 1
	if(nextRoundIndex % 5 == 0):
		player.IncreaseDefaultHealth(1)

	#Start a new round after updating all stats
	var TurnController = get_parent().get_node("TurnController") as TurnController
	TurnController.StartNewRound()




func IncreasePercentage(baseAmount:float,Percentage:float) ->float:	
	return (Percentage / 100) * baseAmount

func UpdateStatLabels(inPlayer:Player):
	healthlabel.text = "Health: " + str(inPlayer.Health)
	damageLabel.text = "Damage: " + str(inPlayer.Damage)
	hitChance.text = "Hit Chance: " + str(inPlayer.HitChance) + "%"
	critChanceLabel.text = "Crit Chance: " + str(inPlayer.CritChance)+"%"
	critLabel.text = "Crit: " + str(inPlayer.CritIncrease) +"%"
