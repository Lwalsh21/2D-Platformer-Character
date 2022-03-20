extends Node


var configfile
const SAVE_PATH = "res://settings.cfg"
var save_file = configfile.new()

onready var hud
onready var coins
onready var mines

func _unhandled_input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()


var save_data = {
	"general" : {
		"score":0
		,"health":100
		,"coins":[]
		,"mines":[]
	}
}

func _ready():
	update_score(0)
	update_health(0)

func update_score(s):
	save_data["general"]["score"] += s
	HUD.find_node("Score").text = "score: " + str(save_data["general"]["score"])

func update_health(h):
	save_data["general"]["health"] += s
	HUD.find_node("Health").text = "Health: " + str(save_data["general"]["health"])


func restart_level():
	HUD = get_node_or_null("/root/Game/UI/HUD")
	Coins = get_node_or_null("/root/Game/Coins")
	Mines = get_node_or_null("/root/Game/Mines")
	
	for c in Coins.get_children():
		c.queue_free()
	for m in Mines.get_children():
		m.queue_free()
	for c in save_data["general"]["coins"]:
		var coin = Coin.instance()
		coin.position = c
		Coins.add_child(coin)
	for m in save_data["general"]["mines"]:
		var mine = Mine.instance()
		mine.position = m
		Mines.add_child(mine)
	update_health(0)
	update_score(0)
	get_tree().paused = false
	

func save_game():
	save_data["general"]["coins"] = []					# creating a list of all the coins that appear in the scene
	save_data["general"]["mines"] = []					# creating a list of all the mines in the scene
	for c in Coins.get_children():						# returns a list of all the nodes in /Game/Coins
		save_data["general"]["coins"].append(c.position)		# adds the coins to the list
	for m in Mines.get_children():
		save_data["general"]["mines"].append(m.position)
	for section in save_data.keys():					# Go through all the coins and mines and add them as keys to the config file
		for key in save_data[section]:
			save_file.set_value(section, key, save_data[section][key])
	save_file.save(SAVE_PATH)						# write the data to the config file

func load_game():
	var error = save_file.load(SAVE_PATH)					# load the keys out of the config file
	if error != OK:								# if there's a problem reading the file, print an error
		print("Failed loading file")
		return
	
	save_data["general"]["coins"] = []					# initialize a list to temporarily hold the coins and mines
	save_data["general"]["mines"] = []
	for section in save_data.keys():
		for key in save_data[section]:					# go through everything in the config file and add it to the lists
			save_data[section][key] = save_file.get_value(section, key, null)
	var _scene = get_tree().change_scene_to(Game)				# reset the scene
	call_deferred("restart_level")						# when the scene has been loaded, call the reset_level method
