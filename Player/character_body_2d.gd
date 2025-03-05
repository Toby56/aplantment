extends CharacterBody2D
@onready var sprite:AnimatedSprite2D = $CharacterSprite

const SPEED = 150.0


func _physics_process(delta: float) -> void:


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if direction:
		velocity = Vector2(direction.x,direction.y).normalized()*SPEED
		
		
		if direction.x>0:
			sprite.play("walk_right")
		elif direction.x<0:
			sprite.play("walk_left")
		elif direction.y<0:
			sprite.play("walk_up")
		elif direction.y>0:
			sprite.play("walk_down")
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		sprite.stop()
	move_and_slide()
