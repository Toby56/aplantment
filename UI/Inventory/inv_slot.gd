extends Resource

class_name InvSlot

@export var item:InvItem
@export var count:int

func _init(item_val:InvItem, count_val:int) -> void:
	item = item_val
	count = count_val
