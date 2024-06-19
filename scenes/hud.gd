extends CanvasLayer

var attackCooldown: bool
var gameState: bool


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D/Sprite2D.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().gameRunning:
		if Input.is_action_pressed("attack"):
			if gameState == true:
				$Sprite2D/Sprite2D.visible = true
				$Sprite2D/Sprite2D/AnimationPlayer.play("attack timeout")
