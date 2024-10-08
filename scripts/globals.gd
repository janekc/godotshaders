extends Node2D

var current_scene = null

var framerate = 60 # target framerate
var target_ip = "10.10.10.54"  # Art-Net receiver IP address
var dot_count = 20  # Number of dots
var in_menu = false # var to store state if player is in menu
var fixture

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
