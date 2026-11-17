extends Node2D



var score = 0

@onready var click : TextureButton = $Canvas/Rocket
@onready var rocketparticles : CPUParticles2D = $"Canvas/Rocket/Rocket Particles"

const save_path = "user://userdata.savefile"


signal score_changed


func save_data():
	var data = {
		"score" : score
	}
	var file = FileAccess.open(save_path , FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			score = data.get("score" , 0)
	else:
		save_data()



func _ready():
	load_data()
	click.pivot_offset = click.size / 2
	$Canvas/Score.text = str(score)




func _on_rocket_button_down():
	var tween = get_tree().create_tween()
	tween.tween_property(click , "scale" , Vector2(.95 ,.95) , .1)





func _on_rocket_button_up():
	var tween = get_tree().create_tween()
	tween.tween_property(click , "scale" , Vector2(1 , 1) , .1)
	score += 1
	emit_signal("score_changed")
	save_data()
	$Canvas/Score.text = str(score)
	rocketparticles.emitting = true
	
