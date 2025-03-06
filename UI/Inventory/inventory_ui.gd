extends Control

@export var container:GridContainer
@onready var inv:Inventory = preload("res://Player/player_inventory.tres")
@onready var inv_slot = preload("res://UI/Inventory/inv_ui_slot.tscn")
@onready var grid: GridContainer = $NinePatchRect/TextureRect/MarginContainer/GridContainer

var is_open = false
var slots:Array

func _ready() -> void:
	close()
	create_slots()
	update_slots()

func create_slots():
	for i in range(inv.inv_items.size()):
		var slot = inv_slot.instantiate()
		grid.add_child(slot)
	slots = grid.get_children()

func update_slots():
	for i in range(min(inv.inv_items.size(),slots.size())):
		slots[i].update(inv.inv_items[i])


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		if is_open:
			close()
		else:
			open()


func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false
