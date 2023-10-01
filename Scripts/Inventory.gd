extends Control

class_name  Inventory


@onready var slotScene =preload("res://Scenes/InventorySlot.tscn")
@onready var inventoryContainer:GridContainer = $"ColorRect/GridContainer"
@onready var inventoryRectangle:ColorRect = $"ColorRect"
@onready var columnCount = inventoryContainer.columns


var inventorySlots := []
var itemHeld = null
var currentSlot = null
var canPlace:bool = false
var iconAnchor:Vector2

var itemsInInventory :=[]

# Called when the node enters the scene tree for the first time.
func _ready():

	#Generate slots for the Inventory
	for i in range(20):
		CreateSlots()


func _process(delta):
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
	itemHeld = null
	ClearGrid()


func PickupItem():

	#check if above a item 
	if not currentSlot or not currentSlot.item_stored:
		if CheckForItemOutsideBounds() == true :
			return


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
	print("Checking For Items")
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
	var player = get_parent().get_node("Player") as Player
	#reset the stats so we dont constantly increase for same items
	player.ResetStats()

	#get all the items in the inventory and update the stats
	for item in itemsInInventory:
		player.Damage += IncreasePercentage(player.Damage,item.damage)
		player.HitChance += IncreasePercentage(player.HitChance,item.hitChance)
		player.IncreasePlayerHealth(item.increaseHealth)

	#start the new round



func IncreasePercentage(baseAmount:float,Percentage:float) ->float:	
	return (Percentage / 100) * baseAmount

