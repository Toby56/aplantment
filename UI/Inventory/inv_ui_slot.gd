extends Panel

@onready var item_display:Sprite2D = $CenterContainer/Panel/item_display

func update(item:InvItem):
	if !item:
		#item_display.visible = false
		item_display.texture = null
	else:
		item_display.texture = item.texture
		#item_display.visible = true
