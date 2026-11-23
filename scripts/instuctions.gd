extends Node2D


@onready var close :TextureButton = $CanvasLayer/CLOSE

func _ready():
	close.pivot_offset = close.size / 2









func _on_close_button_down():
	var tween = get_tree().create_tween()
	tween.tween_property(close , "scale" , Vector2(.9 ,.9), .1)





func _on_close_button_up():
	var tween = get_tree().create_tween()
	tween.tween_property(close , "scale" , Vector2(1 ,1) , .1)
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
