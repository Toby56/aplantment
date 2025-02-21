extends CanvasLayer

@onready var color_rect:ColorRect = $ColorRect
@onready var animation_player:AnimationPlayer = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.visible = false
	

func transition_scene(new_scene):
	ResourceLoader.load_threaded_request(new_scene)
	color_rect.visible = true
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	while ResourceLoader.load_threaded_get_status(new_scene) != 3:
		pass #wait lmao
	var packed_scene = ResourceLoader.load_threaded_get(new_scene)
	get_tree().change_scene_to_packed(packed_scene)
	animation_player.play("fade_out")
	await animation_player.animation_finished
	color_rect.visible = false
