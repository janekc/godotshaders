#extends Node
#
#var udp := PacketPeerUDP.new()
#var target_ip = "192.168.0.100"  # The IP address of the Art-Net receiver (e.g., lighting controller)
#var target_port = 6454  # Art-Net typically uses port 6454
#
#func _ready():
	#send_artnet_packet()
#
#func send_artnet_packet():
	#var packet = create_artnet_packet()
	#
	## Connect the UDP socket to the target address and port
	#udp.connect_to_host(target_ip, target_port)
#
	## Send the packet
	#udp.put_packet(packet)
	#
	## Close the UDP connection
	#udp.close()
#
#func create_artnet_packet() -> PackedByteArray:
	#var packet = PackedByteArray()
	#
	## Art-Net packet example (just header for simplicity, you need to add full protocol data)
	#packet.append_array("Art-Net".to_ascii_buffer())  # 8-byte Art-Net ID
	#packet.append(0x00)  # Null-termination for Art-Net ID
	#packet.append(0x00)  # OpCode (high byte, ArtDMX = 0x5000)
	#packet.append(0x50)  # OpCode (low byte, ArtDMX = 0x5000)
	#packet.append(14)    # Protocol version (high byte)
	#packet.append(0)     # Protocol version (low byte)
	#
	## You will need to continue constructing the full Art-Net packet,
	## adding the necessary fields like sequence, universe, DMX data, etc.
#
	#return packet
