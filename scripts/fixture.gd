extends Node2D

# Constants for the fixture
const DOT_RADIUS = 5  # Radius of each dot
const DOT_SPACING = 20  # Spacing between dots
const MAX_LENGTH = 1920  # Maximum length of the line
const MIN_LENGTH = 50  # Minimum length of the line
const TARGET_PORT = 6454  # Art-Net port
const UNIVERSE = 0  # Art-Net universe

# Variables to track the line size and interaction state
var line_length = 200  # Initial length of the line
var is_moving = false  # Whether the fixture is being moved
var is_resizing = false  # Whether the line is being resized
var start_position = Vector2()  # Starting position of the line
var drag_offset = Vector2()  # Mouse offset for dragging the fixture

var udp := PacketPeerUDP.new()  # UDP instance for sending Art-Net packets
var rgb_data = []  # RGB data for each dot

var target_ip = "10.10.10.54"  # Art-Net receiver IP address
var dot_count = 20  # Number of dots

func _ready():
	# Initialize RGB data with default colors
	for i in range(dot_count):
		rgb_data.append(Color(0, 0, 0))  # Initialize with black color
	
	# Connect the UDP socket to the target address and port
	udp.connect_to_host(target_ip, TARGET_PORT)
	
	# Position the fixture node at the center of the screen
	var viewport_size = get_viewport().size
	global_position = viewport_size / 2


func _draw():
	var step = line_length / (dot_count - 1)  # Calculate the step between each dot
	
	for i in range(dot_count):
		var dot_position = Vector2(i * step, 0)  # Calculate the position of each dot
		#draw_circle(dot_position, DOT_RADIUS, Color.WHITE)  # Draw the dot
		draw_arc(dot_position, DOT_RADIUS, 0, 2 * PI, 32, Color.WHITE)  # Draw the outer circle (dot)

	# Draw the end marker for resizing
	draw_circle(Vector2(line_length, 0), DOT_RADIUS * 1.5, Color.RED)


func _process(delta):
	if is_moving or is_resizing:
		queue_redraw()  # Update drawing only when moving or resizing
	update_dot_colors_from_scene()  # Update dot colors based on the scene
	send_artnet_packet()


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			var mouse_pos = event.position

			# Check if user clicked on the end point to resize
			if (mouse_pos - (global_position + Vector2(line_length, 0))).length() < DOT_RADIUS * 2:
				is_resizing = true
			elif (mouse_pos - global_position).length() < line_length:  # Check if user clicked on the line to move it
				is_moving = true
				drag_offset = mouse_pos - global_position
		else:
			is_moving = false
			is_resizing = false

	elif event is InputEventMouseMotion:
		var mouse_pos = event.position

		# Handle moving the fixture
		if is_moving:
			global_position = mouse_pos - drag_offset

		# Handle resizing the line
		if is_resizing:
			var new_length = (mouse_pos - global_position).length()
			# Limit the length to a reasonable range
			line_length = clamp(new_length, MIN_LENGTH, MAX_LENGTH)


# Function to update RGB data based on the scene colors at dot positions
func update_dot_colors_from_scene():
	var screen_texture = get_viewport().get_texture()
	var image = screen_texture.get_image()
	
	var step = line_length / (dot_count - 1)  # Calculate the step between each dot
	for i in range(dot_count):
		var dot_position = Vector2(i * step, 0) + global_position  # Calculate absolute position
		var color
		if dot_position.x >= 0 and dot_position.x < image.get_width() and dot_position.y >= 0 and dot_position.y < image.get_height():
			color = image.get_pixel(dot_position.x, dot_position.y)
		else:
			color = Color(0, 0, 0)
		rgb_data[i] = color


# Function to send Art-Net packet
func send_artnet_packet():
	var packet = create_artnet_packet()
	
	# Send the packet
	udp.put_packet(packet)


# Function to create an Art-Net packet
func create_artnet_packet() -> PackedByteArray:
	var packet = PackedByteArray()
	packet.append_array("Art-Net".to_ascii_buffer())  # Art-Net ID
	packet.append(0x00)  # Null-termination for Art-Net ID
	packet.append(0x00)  # OpCode (high byte, ArtDMX = 0x5000)
	packet.append(0x50)  # OpCode (low byte, ArtDMX = 0x5000)
	packet.append(0x00)  # Protocol version (high byte)
	packet.append(0x0E)  # Protocol version (low byte)

	packet.append(0)  # Sequence
	packet.append(0)  # Physical port
	packet.append(UNIVERSE & 0xFF)  # Universe (low byte)
	packet.append((UNIVERSE >> 8) & 0xFF)  # Universe (high byte)

	# Length of DMX data
	var dmx_length = dot_count * 3  # 3 bytes per dot (RGB)
	packet.append((dmx_length >> 8) & 0xFF)  # High byte of length
	packet.append(dmx_length & 0xFF)  # Low byte of length

	# Add RGB data for each dot
	for color in rgb_data:
		packet.append(int(color.r * 255))  # Red
		packet.append(int(color.g * 255))  # Green
		packet.append(int(color.b * 255))  # Blue

	return packet


func print_all_nodes():
	var main_scene = get_tree().get_root().get_node("Mainscene")
	if main_scene:
		for child in main_scene.get_children():
			print(child.name)
	else:
		print("MainScene not found")


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		udp.close()
		get_tree().quit() # default behavior


# Function to set the target IP address
func set_target_ip(ip: String):
	udp.close()
	target_ip = ip
	udp.connect_to_host(target_ip, TARGET_PORT)

# Function to set the number of dots
func set_dot_count(count: int):
	dot_count = count
	rgb_data.resize(dot_count)
	for i in range(dot_count):
		rgb_data[i] = Color(0, 0, 0)  # Initialize with black color
	queue_redraw()  # Redraw the fixture with the new dot count
