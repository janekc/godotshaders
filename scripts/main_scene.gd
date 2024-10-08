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

var 	fixture_node = load("res://scenes/fixture.tscn").instantiate()  # Reference to the 2D line fixture
var 	settings = load("res://scenes/SettingsUI.tscn").instantiate()

# Variable to track the current scene index
var current_scene_index = 0




# Called when the node is ready
func _ready():
	# Load the first scene
	load_scene(scenes[current_scene_index])
	Engine.set_max_fps(Globals.framerate)
	
	Globals.fixture = fixture_node
	
	add_child(Globals.fixture)
	Globals.fixture.z_index = 100


# Function to load a new scene
func load_scene(scene_path: String):
	var new_scene = load(scene_path).instantiate()
	
	# Remove the current scene (but keep the fixture)
	for child in get_children():
		if child != Globals.fixture:  # Don't remove the fixture
			remove_child(child)
			child.queue_free()

	# Add the new scene
	add_child(new_scene)


# Handle input
func _input(event):
	# Check if the right key is pressed
	if event.is_action_pressed("ui_right"):
		if ! Globals.in_menu:
			cycle_scene(1)  # Go to next scene

	# Check if the left key is pressed (optional for going backward)
	if event.is_action_pressed("ui_left"):
		if ! Globals.in_menu:
			cycle_scene(-1)  # Go to previous scene

	if event.is_action_pressed("ui_cancel"):
		open_menu()


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


func open_menu():
	if ! Globals.in_menu:
		add_child(settings)
	else:
		remove_child(settings)
	
	Globals.in_menu = not Globals.in_menu
