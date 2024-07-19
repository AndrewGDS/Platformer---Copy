extends Area2D

func _on_Hitbox_body_entered(body):
	if body is PlayerPlatform:
		get_tree().reload_current_scene()
