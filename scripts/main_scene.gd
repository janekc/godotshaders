extends Node

# Array of paths to your scenes
var scenes = [
	"res://scenes/combustible_vonoroi.tscn",
	"res://scenes/combustible_vonoroi_with_parameters.tscn",
	"res://scenes/cosine_water.tscn",
	"res://scenes/creation.tscn",
	"res://scenes/drops.tscn",
	"res://scenes/energyBeams.tscn",
	"res://scenes/kinetic_pupils.tscn",
	"res://scenes/phantom_star.tscn",
	"res://scenes/protean_clouds.tscn",
	"res://scenes/quadrilateral_grid.tscn",
	"res://scenes/raymarching.tscn",
	"res://scenes/slab_steps.tscn",
	"res://scenes/speedlines.tscn",
	"res://scenes/starfield_angeled.tscn",
	"res://scenes/starfield_angeled.tscn",
	"res://scenes/starry_infinite_tunnel.tscn",
	"res://scenes/stars.tscn",
	"res://scenes/vaporwave_grid_tweaks.tscn",
	"res://scenes/vonoroi_synapse.tscn"
]

# Variable to track the current scene index
var current_scene_index = 0
var fixture_node  # Reference to the 2D line fixture
var settings_ui


# Called when the node is ready
func _ready():
	# Load the first scene
	load_scene(scenes[current_scene_index])
	Engine.set_max_fps(60)
	# Load the SettingsUI scene
	var settings_ui_scene = preload("res://scenes/SettingsUI.tscn")
	settings_ui = settings_ui_scene.instantiate()
	add_child(settings_ui)

	# Connect the Apply button signal
	var apply_button = settings_ui.get_node("ApplyButton")
	
	for child in settings_ui.get_children():
		print(child.name)
	
	if apply_button:
		pass
		#apply_button.connect("pressed", self, "_on_apply_button_pressed")
	else:
		print("ApplyButton not found in SettingsUI")
	

# Function to load a new scene
func load_scene(scene_path: String):
	var new_scene = load(scene_path).instantiate()
	
	# Remove the current scene (but keep the fixture)
	for child in get_children():
		if child != fixture_node:  # Don't remove the fixture
			remove_child(child)
			child.queue_free()

	# Add the new scene
	add_child(new_scene)
	
	# Add the fixture (load it from a separate scene or script)
	# Assuming you created a separate scene for the fixture, instantiate and add it
	fixture_node = preload("res://scenes/fixture.tscn").instantiate()
	add_child(fixture_node)  # Add the fixture to the main scene


# Handle input
func _input(event):
	# Check if the right key is pressed
	if event.is_action_pressed("ui_right"):
		cycle_scene(1)  # Go to next scene

	# Check if the left key is pressed (optional for going backward)
	if event.is_action_pressed("ui_left"):
		cycle_scene(-1)  # Go to previous scene

	# Delegate mouse events to the fixture if necessary
	fixture_node._input(event)  # Forward input to the fixture

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


func _on_apply_button_pressed():
	# Get user input
	var target_ip = settings_ui.get_node("TargetIPInput").text
	var dot_count = int(settings_ui.get_node("DotCountInput").text)

	# Update the fixture node variables
	fixture_node.set_target_ip(target_ip)
	fixture_node.set_dot_count(dot_count)
