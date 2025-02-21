extends CanvasLayer

@onready var color_rect:ColorRect = $ColorRect
@onready var animation_player:AnimationPlayer = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
var new_scene:String = ""
var loaded = false
func _ready() -> void:
	color_rect.visible = false
	set_process(false)
	
func transition_scene(new_scene_to_load):
	new_scene = new_scene_to_load
	ResourceLoader.load_threaded_request(new_scene)
	color_rect.visible = true
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	set_process(true)
	
	
	
func _process(delta: float) -> void:
	#print(1)
	if not loaded:
		if ResourceLoader.load_threaded_get_status(new_scene) == 3:
			loaded = true
			var packed_scene = ResourceLoader.load_threaded_get(new_scene)
			get_tree().change_scene_to_packed(packed_scene)
			animation_player.play("fade_out")
			await animation_player.animation_finished
			color_rect.visible = false
			loaded = false
			set_process(false)
