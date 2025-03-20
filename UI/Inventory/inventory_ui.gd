extends Control

@onready var inv:Inventory = preload("res://Player/player_inventory.tres")
@onready var inv_ui_slot = preload("res://UI/Inventory/inv_ui_slot.tscn")
@onready var grid: GridContainer = $NinePatchRect/MarginContainer/GridContainer
@onready var couches = preload("res://UI/Inventory/InvItems/couches.tres")


var is_open = false
var mouse_slot = InvSlot.new(null, 0)
var mouse_panel:TextureRect
var ui_slots:Array

func _ready() -> void:
	close()
	mouse_panel = inv_ui_slot.instantiate()
	mouse_panel.texture = null
	mouse_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(mouse_panel)
	create_slots()
	update_slots()

func create_slots():
	for i in range(8):
		var slot:TextureRect = inv_ui_slot.instantiate()
		grid.add_child(slot)
		ui_slots.append(slot)
		slot.gui_input.connect(on_slot_pressed.bind(i))
		slot.mouse_entered.connect(on_slot_hover.bind(slot))
		inv.inv_items.append(InvSlot.new(couches, i))

func update_slots():
	for i in range(min(inv.inv_items.size(),ui_slots.size())):
		if inv.inv_items[i].item:
			ui_slots[i].update(inv.inv_items[i].item,inv.inv_items[i].count)
		else:
			ui_slots[i].update(null)

func on_slot_pressed(input:InputEvent, slot_num):
	var item_in_inv = inv.inv_items[slot_num]
	if input.is_action_pressed("left_mouse_click"):
		if mouse_slot.item == item_in_inv.item:
			if (mouse_slot.count + item_in_inv.count - item_in_inv.item.stack_size<=0):
				item_in_inv.count+= mouse_slot.count
				mouse_slot.item = null
				mouse_slot.count = 0
			else:
				var difference = item_in_inv.item.stack_size - item_in_inv.count
				item_in_inv.count = item_in_inv.item.stack_size
				mouse_slot.count-=difference
				
		else:
			var temp = [item_in_inv.item, item_in_inv.count]
			item_in_inv.item = mouse_slot.item
			item_in_inv.count = mouse_slot.count
			mouse_slot.item = temp[0]
			mouse_slot.count = temp[1]
				
	elif input.is_action_pressed("right_mouse_click"):
		if mouse_slot.item!=null:
			if item_in_inv.item==null:
				item_in_inv.item = mouse_slot.item
				item_in_inv.count = 1
				mouse_slot.count-=1
				if mouse_slot.count == 0: mouse_slot.item = null
			elif item_in_inv.item == mouse_slot.item:
				if item_in_inv.count<item_in_inv.item.stack_size:
					item_in_inv.count+=1
					mouse_slot.count-=1
					if mouse_slot.count == 0: mouse_slot.item = null
		else:
			if item_in_inv.item!=null:
				mouse_slot.item = item_in_inv.item
				mouse_slot.count = ceili(item_in_inv.count/2.0)
				item_in_inv.count -= mouse_slot.count
				if item_in_inv.count == 0: item_in_inv.item=null
		
	ui_slots[slot_num].update(inv.inv_items[slot_num].item, inv.inv_items[slot_num].count)
	mouse_panel.update(mouse_slot.item, mouse_slot.count)

func on_slot_hover(slot:TextureRect):
	slot.self_modulate.a=0.1

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		if is_open:
			close()
		else:
			open()
	if Input.is_action_just_pressed("ui_accept"):
		insert_item(couches, 2)
	mouse_panel.global_position = get_global_mouse_position()
	


func insert_item(item:InvItem, count:int):
	for slot in inv.inv_items:
		if slot.item == item:
			if slot.count + count <= item.stack_size:
				slot.count += count
				break
			else:
				count-= item.stack_size - slot.count
				slot.count = item.stack_size
	for slot in inv.inv_items:
		if slot.item == null:
			slot.item = item
			if count<=item.stack_size:
				slot.count = count
			else:
				slot.count = item.stack_size
				count-=item.stack_size
	update_slots()


func open():
	update_slots()
	visible = true
	is_open = true
	#set_process(true)

func close():
	visible = false
	is_open = false
	#set_process(false)
