extends Node2D



var score = 0
var stage1 = false
var stage2 = false
var stage3 = false
var stage4 = false
var zoomclik = false
var clicked = false
var rebirth = 0
var multiplier = 1
var requirement = 0
var clicksrng = {"normal" = 1000,
				"normal1" = 500,
				"normal2" = 250,
				"normal3" = 10}
var rngnum = RandomNumberGenerator.new()




@onready var click : TextureButton = $Zoom/Rocket
@onready var rocketparticles : CPUParticles2D = $"Zoom/Rocket/Rocket Particles"
@onready var backgroundanim : AnimationPlayer = $Canvas/Animation
@onready var camera : Camera2D = $Zoom
@onready var reb:TextureButton = $Canvas/Rebirth
@onready var rebmenu:Sprite2D = $"Canvas/Rebirth Menu"
@onready var rebclose : TextureButton = $"Canvas/Rebirth Menu/Close Rebirth"
@onready var confreb :TextureButton = $"Canvas/Rebirth Menu/Confirm"
@onready var rebparticles:CPUParticles2D = $"Zoom/Rocket/Rebirth Particles"


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
signal rebirth_changed
signal multiplier_changed

func save_data():
	var data = {
		"score" : score,
		"rebirth": rebirth,
		"multiplier": multiplier,
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
			rebirth = data.get("rebirth" , 0)
			multiplier = data.get("multiplier" , 1)
	else:
		save_data()



func _ready():
	confreb.pivot_offset = confreb.size / 2
	reb.visible = true
	rebmenu.visible = false
	rebclose.pivot_offset = rebclose.size / 2
	reb.pivot_offset = reb.size / 2
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
		score += (1 * multiplier)
	if roll == "normal1":
		score += (2 * multiplier)
	if roll == "normal2":
		score += (3 * multiplier)
	if roll == "normal3":
		score += (4 * multiplier)
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





func _on_rebirth_button_down():
	var tween = get_tree().create_tween()
	tween.tween_property(reb , "scale" , Vector2(.9 ,.9),.1)





func _on_rebirth_button_up():
	var tween = get_tree().create_tween()
	tween.tween_property(reb , "scale" , Vector2(1 , 1) , .1)
	rebmenu.visible = true
	reb.visible = false
	if score >= requirement:
		$"Canvas/Rebirth Menu/Info".text = "SCORE = " + str(score) +"
REQUIREMENT = " + str(requirement) +"
REQUIREMENT IS MET  
MULTIPLIER = " + str(multiplier) + "
INCREASED MULTIPLIER = " + str(multiplier * 2)
	else:
		$"Canvas/Rebirth Menu/Info".text = "SCORE = " + str(score) +"
REQUIREMENT = " + str(requirement) +"
REQUIREMENT IS NOT MET  
MULTIPLIER = " + str(multiplier) + "
INCREASED MULTIPLIER = " + str(multiplier * 2)




func _on_close_rebirth_button_down():
	var tween = get_tree().create_tween()
	tween.tween_property(rebclose , "scale" , Vector2(.9 ,.9) , .1)




func _on_close_rebirth_button_up():
	var tween = get_tree().create_tween()
	tween.tween_property(rebclose , "scale" , Vector2(1 , 1) , .1)
	rebmenu.visible = false
	reb.visible = true





func _on_confirm_button_down():
	var tween = get_tree().create_tween()
	tween.tween_property(confreb , "scale" , Vector2(.9 ,.9), .1)





func _on_confirm_button_up():
	var tween = get_tree().create_tween()
	tween.tween_property(confreb , "scale" , Vector2(1 , 1) , .1)
	hideui()
	if score >= requirement:
		rebparticles.emitting = true
		backgroundanim.play("Rebirth")
		await get_tree().create_timer(1).timeout
		rebparticles.emitting = false

func showui():
	reb.visible = true


func hideui():
	reb.visible = false
	rebmenu.visible = false


func rebirthtrue():
	rebirth += 1
	score = 0
	multiplier = (multiplier *2)
	emit_signal("score_changed")
	emit_signal("rebirth_changed")
	emit_signal("multiplier_changed")
	save_data()
