extends Node2D

class_name Item

@export var itemIcon:TextureRect

var itemID:int
var itemGrids:=[]
var selected:bool = false
var gridAnchor = null

#Stats
var damage:float = 25
var hitChance:float = 0
var healingItem:bool = false
var healAmount:int = 0
var increaseHealth:int = 0
var critChance:float = 0
var critIncrease:float = 0
var armor:int = 0



func _ready():
	pass


func _process(delta):
	if selected:
		global_position = lerp(global_position,get_global_mouse_position(),25 * delta)

func LoadItem(InItemID:int):
	var iconPath = "res://Sprites/" + DataHandler.itemData[str(InItemID)]["Name"] + ".png"
	itemIcon.texture = load(iconPath)

	#get the items stats
	var stats = DataHandler.itemData[str(InItemID)]["Stats"]
	damage = stats["Damage"]
	hitChance = stats["HitChance"]
	healingItem = stats["HealingItem"]
	healAmount = stats["HealingAmount"]
	increaseHealth = stats["IncreaseHealth"]
	critChance = stats["CritChance"]
	critIncrease = stats["CritIncrease"]
	armor = stats["Armor"]


	#Get the items grids for sizing in inventory
	for grid in DataHandler.itemGrid[str(InItemID)]:
		var convertArray :=[]
		for i in grid:
			convertArray.push_back(int(i))
		itemGrids.push_back(convertArray)





func CheckForPoint() ->bool:
	if itemIcon.get_global_rect().has_point(get_global_mouse_position()):
		print(self.name)
		return true
	return false

func SnapTo(destination:Vector2):
	var tween = get_tree().create_tween()

	if int(rotation_degrees) % 180 == 0:
		destination += itemIcon.size / 2
	else:
		var tempXY = Vector2(itemIcon.size.y,itemIcon.size.x)
		destination += tempXY / 2


	tween.tween_property(self,"global_position",destination,.15).set_trans(Tween.TRANS_SINE)
	selected = false


func RotateItem():
	for grid in itemGrids:
		var tempY = grid[0]
		grid[0] = -grid[1]
		grid[1] = tempY
	rotation_degrees += 90
	if rotation_degrees >= 360:
		rotation_degrees = 0

