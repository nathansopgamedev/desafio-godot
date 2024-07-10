extends Node2D

@export var regen_amount : int = 10

func _ready():
	$Area2D.body_entered.connect(on_body_entered)
	
	
func on_body_entered(body : Node2D):
	if body.is_in_group("Player"):
		var player : Player = body
		player.heal(regen_amount)
		player.meat_collected.emit(regen_amount)
		queue_free()
