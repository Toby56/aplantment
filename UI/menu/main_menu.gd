extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continue_pressed() -> void:
	var next_scene = "res://UI/menu/start_game.tscn"
	LoadingScreen.transition_scene(next_scene)
	
func _on_quit_pressed() -> void:
	get_tree().quit()
	
