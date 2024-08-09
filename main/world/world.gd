class_name World extends Node2D

const ROOM_PATH: String = "res://main/world/room/"

var is_paused: bool = false
var loaded_room: Room
var loaded_room_name: String

func load_room(room_name: String, anchor: String = "Default", trans_in: bool = true, out_direction: String = "down") -> void:
	is_paused = true
	
	if is_instance_valid(loaded_room) and trans_in:
		await Ref.transition.trans_in()
	
	var old_name: String = loaded_room_name 
	loaded_room_name = room_name # items need the loaded room name
	
	var path: String = ROOM_PATH + "%s/%s.tscn" % [room_name.to_lower(), room_name.to_lower()]
	var new_room: Room = load(path).instantiate()
	add_child(new_room)
	move_child(new_room, 0)
	
	if not is_instance_valid(loaded_room):
		await new_room.load_in()
	elif is_instance_valid(loaded_room) and old_name == room_name:
		new_room.queue_free()
		new_room = loaded_room
	else:
		await loaded_room.load_out()
		await new_room.load_in()
		
		loaded_room.queue_free()
	
	loaded_room = new_room
	loaded_room_name = room_name
	
	Ref.player.latest_input = out_direction
	Ref.player.play_look_animation()
	Ref.player.set_limit(loaded_room.get_bounds())
	Ref.player.facing_dir = Ref.player.DIR_MAP[out_direction]
	Ref.player.global_position = loaded_room.get_node("Anchors/" + anchor).global_position
	
	await Ref.transition.trans_out()
	
	is_paused = false
