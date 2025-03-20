extends TextureRect

@onready var item_display:Sprite2D = $CenterContainer/Panel/item_display
@onready var count_label: Label = $CenterContainer/Panel/Label

var item_slot:InvItem
var count:int

func update(item:InvItem, item_count:int = 0):
	if !item:
		#item_display.visible = false
		item_display.texture = null
		count_label.text = ""
		item_slot = null
	else:
		item_slot = item
		count = item_count
		item_display.texture = item.texture
		if count!=1:
			count_label.text = str(count)
		else:
			count_label.text = ""
		#item_display.visible = true
func is_empty():
	if item_slot:
		return item_slot.name
	else:
		return "empty"
