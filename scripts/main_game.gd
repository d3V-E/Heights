extends Node2D



var score = 0
var stage1 = false
var stage2 = false
var stage3 = false
var stage4 = false
var zoomclik = false
var clicked = false
var clicksrng = {"normal" = 1000,
				"normal1" = 500,
				"normal2" = 250,
				"normal3" = 10}
var rngnum = RandomNumberGenerator.new()



@onready var click : TextureButton = $Zoom/Rocket
@onready var rocketparticles : CPUParticles2D = $"Zoom/Rocket/Rocket Particles"
@onready var backgroundanim : AnimationPlayer = $Canvas/Animation
@onready var camera : Camera2D = $Zoom


func clickchance():
	rngnum.randomize()
	
	var x = 0
	
	for i in clicksrng:
		x += clicksrng[i]
	
	var item = rngnum.randi_range(0 , x)
	
	for i in clicksrng:
		if item <=  clicksrng[i]:
			return i
		item -= clicksrng[i]
	return "normal"

const save_path = "user://userdata.savefiles"


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
	backgroundanim.play("RESET")
	load_data()
	click.pivot_offset = click.size / 2
	$Zoom/Score.text = str(score)




func _on_rocket_button_down():
	var tween = get_tree().create_tween()
	tween.tween_property(click , "scale" , Vector2(.95 ,.95) , .1)





func _on_rocket_button_up():
	var roll = ""
	clicked = true
	var tween = get_tree().create_tween()
	tween.tween_property(click , "scale" , Vector2(1 , 1) , .1)
	roll = clickchance()
	if roll == "normal":
		score += 1
	if roll == "normal1":
		score += 2
	if roll == "normal2":
		score += 3
	if roll == "normal3":
		score += 4
	emit_signal("score_changed")
	save_data()
	$Zoom/Score.text = str(score)
	rocketparticles.emitting = true
	camera.zoom = Vector2(1.01 , 1.01)
	zoomclik = true
	await get_tree().create_timer(1).timeout
	if zoomclik == true:
		zoomclik = false
	clicked = false



func _on_save_timeout():
	if zoomclik == false and clicked == false:
		camera.zoom = Vector2(1 , 1)
	emit_signal("score_changed")
	save_data()
	if score >= 100 and stage1 == false:
		backgroundanim.play("Stage 1")
		stage1 = true
	if score >= 500 and stage2 == false:
		backgroundanim.play("Stage 2")
		stage2 = true
	if score >= 1000 and stage3 == false:
		backgroundanim.play("Stage 3")
		stage3 = true
	if score >= 2500 and stage4 == false:
		backgroundanim.play("Stage 4")
		stage4 = true
