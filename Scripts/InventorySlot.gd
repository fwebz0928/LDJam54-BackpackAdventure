extends TextureRect

class_name InventorySlot

signal slot_entered(slot:InventorySlot)
signal slot_exited(slot:InventorySlot)

@onready var filter = $"Filter"

var slotID
var is_Hovering:bool = false
enum SlotState{DEFAULT,TAKEN,FREE}
var state:SlotState = SlotState.DEFAULT
var item_stored = null




func SetColor(InState:SlotState = SlotState.DEFAULT):
	match InState:
		SlotState.DEFAULT:
			filter.color = Color(Color.WHITE,0.0)
		SlotState.TAKEN:
			filter.color = Color(Color.RED,0.2)
		SlotState.FREE:
			filter.color = Color(Color.GREEN,0.2)
		


func _process(delta):
	if get_global_rect().has_point(get_global_mouse_position()):
		if not is_Hovering:
			is_Hovering = true
			emit_signal("slot_entered",self)
	else:
		if is_Hovering:
			is_Hovering = false
			emit_signal("slot_exited",self)