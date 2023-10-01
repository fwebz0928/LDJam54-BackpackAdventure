extends Node

var itemData
var itemGrid := {}
var itemStats :={}
@onready var itemDataPath = "res://Data/Items.Json"



# Called when the node enters the scene tree for the first time.
func _ready():
	LoadData(itemDataPath)
	SetGridData()
	pass


func LoadData(inPath):
	if not FileAccess.file_exists(inPath):
		print("File not Found")
	var itemFile = FileAccess.open(inPath,FileAccess.READ)
	itemData = JSON.parse_string(itemFile.get_as_text())
	itemFile.close()

func SetGridData():
	for item in itemData.keys():
		var tempGrid :=[]
		for point in itemData[item]["Grid"].split("/"):
			tempGrid.push_back(point.split(","))
		itemGrid[item] = tempGrid

