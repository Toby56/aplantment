extends CharacterBody2D
@onready var sprite:AnimatedSprite2D = $CharacterSprite

const SPEED = 300.0


func _physics_process(delta: float) -> void:


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
		if velocity.y<0:
			sprite.play("walk_up")
		elif velocity.y>0:
			sprite.play("walk_down")
		
		if velocity.x>0:
			sprite.play("walk_right")
		elif velocity.x<0:
			sprite.play("walk_left")
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	move_and_slide()
