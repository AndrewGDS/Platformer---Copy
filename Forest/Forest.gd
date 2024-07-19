extends Node2D

signal Scene_over

func _ready():
	$AnimationPlayer.play("Platform")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("Scene_over")
