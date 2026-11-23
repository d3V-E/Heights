extends Node2D



var c2 = 2750
var c1 = 300
var score = 0
var stage1 = false
var stage2 = false
var stage3 = false
var stage4 = false
var zoomclik = false
var clicked = false
var rebirth = 0
var multiplier = 1
var requirement = 10000
var clicksrng = {"normal" = 1000,
				"normal1" = 500,
				"normal2" = 250,
				"normal3" = 10}
var rngnum = RandomNumberGenerator.new()
var randomevent = {"pass" = 10000,
					"balance" = 1,}
var eventnum = RandomNumberGenerator.new()
var minecount = 0
var minecorrect = 0
var minewrong = 0
var mine = ""
var minecounter = {"SAFE" : 40 , 
					"MINE" : 10}
var minerng = RandomNumberGenerator.new()
var persec = 0


@onready var b1 :TextureButton = $"Canvas/Shopline/ScrollContainer/VBoxContainer/Control/ShopOption/11"
@onready var click : TextureButton = $Zoom/Rocket
@onready var rocketparticles : CPUParticles2D = $"Zoom/Rocket/Rocket Particles"
@onready var backgroundanim : AnimationPlayer = $Canvas/Animation
@onready var camera : Camera2D = $Zoom
@onready var reb:TextureButton = $Canvas/Rebirth
@onready var rebmenu:Sprite2D = $"Canvas/Rebirth Menu"
@onready var rebclose : TextureButton = $"Canvas/Rebirth Menu/Close Rebirth"
@onready var confreb :TextureButton = $"Canvas/Rebirth Menu/Confirm"
@onready var rebparticles:CPUParticles2D = $"Zoom/Rocket/Rebirth Particles"
@onready var canvast = $CanvasM/Backdrop
@onready var mminigame :Sprite2D = $CanvasM/Backdrop
@onready var close:TextureButton = $Canvas/Shopline/Close
@onready var shop:TextureButton = $Canvas/Shop
@onready var instruct:TextureButton = $Canvas/Instruct
@onready var b2 :TextureButton = $"Canvas/Shopline/ScrollContainer/VBoxContainer/Control2/ShopOption/te"


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

func getrandomevent():
	eventnum.randomize()
	
	var y = 0
	for t in randomevent:
		y += randomevent[t]
	
	
	var item1 = eventnum.randi_range(0 , y)
	
	for t in randomevent:
		if item1 <= randomevent[t]:
			return t
		item1 -= randomevent[t]
	return "pass"


const save_path = "user://userdata.savefiles"


signal score_changed
signal rebirth_changed
signal multiplier_changed
signal requirement_changed

func save_data():
	var data = {
		"score" : score,
		"rebirth": rebirth,
		"multiplier": multiplier,
		"requirement" : requirement
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
			requirement = data.get("requirement" , 10000)
	else:
		save_data()



func _ready():
	mminigame.visible = false
	confreb.pivot_offset = confreb.size / 2
	reb.visible = true
	rebmenu.visible = false
	rebclose.pivot_offset = rebclose.size / 2
	reb.pivot_offset = reb.size / 2
	shop.pivot_offset = shop.size / 2
	close.pivot_offset = close.size / 2
	b2.pivot_offset = b2.size / 2
	instruct.pivot_offset = instruct.size / 2
	b1.pivot_offset = b1.size / 2
	backgroundanim.play("RESET")
	load_data()
	click.pivot_offset = click.size / 2
	$Zoom/Score.text = str(score)
	for c in canvast.get_children():
		if c is Button:
			c.pivot_offset = c.size / 2
			c.button_down.connect(_on_any_button_down.bind(c))
			c.button_up.connect(_on_any_button_up.bind(c))




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
	var chosen = getrandomevent()
	if chosen == "pass":
		pass
	elif chosen == "balance":
		minecorrect = 0
		minewrong = 0
		mminigame.visible = true
		newround()



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
	$"Canvas/Rebirth Menu/Rebirth Count".text = str(rebirth)
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
	requirement = requirement * 10
	emit_signal("score_changed")
	emit_signal("rebirth_changed")
	emit_signal("multiplier_changed")
	emit_signal("requirement_changed")
	save_data()






func _on_any_button_down(op: Button):
	var tween = create_tween()
	tween.tween_property(op, "scale", Vector2(.9, .9), .1)

func _on_any_button_up(op: Button):
	var tween = create_tween()
	tween.tween_property(op, "scale", Vector2(1, 1), .1)
	
	mine = get_mines()
	
	if mine == "SAFE":
		op.text = "SAFE"
		minecorrect += 1
	else:
		op.text = "MINE"
		minewrong += 1
	op.disabled = true
	
	if minewrong >= 5:
		score -= float(score / 2)
	
	if minecorrect >= 10:
		mminigame.visible = false

func get_mines():
	minerng.randomize()
	
	var te = 0
	
	for k in minecounter:
		te += minecounter[k]
	
	var itemlot = minerng.randi_range(1 , te)
	
	var check = 0
	for k in minecounter:
		check += minecounter[k]
		if itemlot <= check:
			return k
	return "SAFE"


func _on_autosaver_timeout():
	score += persec
	emit_signal("score_changed")
	emit_signal("multiplier_changed")
	emit_signal("score_changed")
	emit_signal("requirement_changed")
	save_data()



func newround():
	minecount = 0
	minecorrect = 0
	minewrong = 0
	mine = ""
	for c in canvast.get_children():
		if c is Button:
			c.disabled = false
			c.text = ""
			c.scale = Vector2(1, 1)





func _on_shop_button_down():
	var tween = get_tree().create_tween()
	tween.tween_property(shop , "scale" , Vector2(.9 ,.9) ,.1)





func _on_shop_button_up():
	var tween = get_tree().create_tween()
	tween.tween_property(shop , "scale" , Vector2(1 , 1), .1)
	backgroundanim.play("SHOP")






func _on_close_button_down():
	var tween = get_tree().create_tween()
	tween.tween_property(close , "scale" , Vector2(.9 ,.9), .1)






func _on_close_button_up():
	var tween = get_tree().create_tween()
	tween.tween_property(close , "scale" , Vector2(1 , 1), .1)
	backgroundanim.play_backwards("SHOP")




func _on_instruct_button_down():
	var tween = get_tree().create_tween()
	tween.tween_property(instruct , "scale" , Vector2(.9 ,.9), .1)





func _on_instruct_button_up():
	var tween = get_tree().create_tween()
	tween.tween_property(instruct , "scale" , Vector2(1 , 1), .1)
	get_tree().change_scene_to_file("res://scenes/instuctions.tscn")





func _on__button_down():
	var tween = get_tree().create_tween()
	tween.tween_property(b1 , "scale" , Vector2(.9 ,.9), .1)





func _on__button_up():
	var tween = get_tree().create_tween()
	tween.tween_property(b1 , "scale" , Vector2(1 , 1), .1)
	if score >= c1:
		score -= c1
		persec += 1
		c1 += 100
		$"Canvas/Shopline/ScrollContainer/VBoxContainer/Control/ShopOption/1".text = "+ 1 score per second
Cost = " + str(c1)




func _on_te_button_down():
	var tween = get_tree().create_tween()
	tween.tween_property(b2 , "scale", Vector2(.9 ,.9) , .1)





func _on_te_button_up():
	var tween = get_tree().create_tween()
	tween.tween_property(b2 , "scale" , Vector2(1 , 1) ,.1)
