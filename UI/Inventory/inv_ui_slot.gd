extends TextureButton

@onready var item_display:Sprite2D = $CenterContainer/Panel/item_display
@onready var count_label: Label = $CenterContainer/Panel/Label

var item_slot:InvItem

func update(item:InvItem, count:int):
	if !item:
		#item_display.visible = false
		item_display.texture = null
		count_label.text = ""	
	else:
		item_display.texture = item.texture
		if count>1:
			count_label.text = str(count)
		else:
			count_label.text = ""
		#item_display.visible = true
func is_empty():
	if item_display.texture == null:
		return true
	else:
		return false
