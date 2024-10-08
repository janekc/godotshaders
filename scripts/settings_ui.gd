extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("TargetIPInput").grab_focus()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
# Function to set the target IP address

func check_ip(ip: String):
	var ip_pattern = r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$"
	var regex = RegEx.new()
	regex.compile(ip_pattern)
	
	# Check if the provided IP address matches the pattern
	if regex.search(ip):
		return true
	else:
		print("Invalid IP address")
		return false


# Function to set the number of dots
func check_dot_count(count: int):
	if count >= 1 and count < 169:
		return true
	else:
		print("Number of LEDs should be between 1 and 169")
		return false

func _on_apply_button_pressed() -> void:
	var target_ip = get_node("TargetIPInput").text
	var dot_count = int(get_node("DotCountInput").text)

	# Update the fixture node variables
	if check_ip(target_ip):
		Globals.fixture.set_target_ip(target_ip)
	if check_dot_count(dot_count):
		Globals.fixture.set_dot_count(dot_count)
