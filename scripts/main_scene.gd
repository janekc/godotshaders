extends Node

# Array to hold the paths of the scenes
var scenes = []
var current_scene_index = 0

# Folder where the scenes are located
const SCENE_FOLDER = "res://scenes/" # Replace this with your folder path

# Called when the node is ready
func _ready():
	load_scenes_from_folder(SCENE_FOLDER)
	if scenes.size() > 0:
		load_scene(scenes[current_scene_index])
	else:
		print("No scenes found in the folder")

# Function to load scenes from the folder
func load_scenes_from_folder(folder_path: String):
	var dir = DirAccess.open(folder_path)  # Use DirAccess to open the folder
	if dir:
		dir.list_dir_begin()  # Begin listing files
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				scenes.append(folder_path + file_name)  # Add full path of the scene file
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open directory: " + folder_path)

# Function to load a scene
func load_scene(scene_path: String):
	var scene = load(scene_path)  # Load the PackedScene
	var scene_instance = scene.instantiate()  # Create an instance of the scene
	# Clear the current scene
	for child in get_children():
		remove_child(child)
		child.queue_free()
	# Add the new scene instance to the main scene
	add_child(scene_instance)

# Handle input
func _input(event):
	# Check if the right key is pressed
	if event.is_action_pressed("ui_right"):
		cycle_scene(1)  # Go to the next scene
	# Check if the left key is pressed (optional for going backward)
	if event.is_action_pressed("ui_left"):
		cycle_scene(-1)  # Go to the previous scene

# Function to cycle through scenes
func cycle_scene(direction: int):
	current_scene_index += direction
	# Wrap around the index
	if current_scene_index >= scenes.size():
		current_scene_index = 0
	elif current_scene_index < 0:
		current_scene_index = scenes.size() - 1

	# Load the new scene
	load_scene(scenes[current_scene_index])
