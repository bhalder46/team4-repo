extends Area2D

@onready var animation_player = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		animation_player.play("levelIntro")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "levelIntro":
		# Stop monitoring and disable further body entering
		monitoring = false
		set_monitorable(false)
