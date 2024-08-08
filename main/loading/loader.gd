class_name Loader extends CanvasLayer

@export var panel_scene: PackedScene

func _ready() -> void:
	load_materials.call_deferred("res://main")
	# not sure of another way to ensure shader/particles are cached;
	# maybe will not work for larger projects
	await get_tree().create_timer(1.0).timeout
	for child in get_children():
		child.queue_free()

func load_materials(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	for sub_dir in dir.get_directories():
		load_materials(path + "/" + sub_dir)
	for file in dir.get_files():
		if file.contains(".tscn"):
			var actual_name: String = file.split(".")[0]
			var root: Node = load(path + "/" + actual_name + ".tscn").instantiate()
			var stack: Array[Node] = [root]
			while len(stack) > 0:
				var node: Node = stack.pop_back()
				if node is CanvasItem and node.material:
					var material_rect: ColorRect = panel_scene.instantiate()
					material_rect.material = node.material
					%GridContainer.add_child(material_rect)
				if node is CPUParticles2D:
					node.owner = null
					node.get_parent().remove_child(node)
					add_child(node)
					node.emitting = true
					
				stack.append_array(node.get_children() as Array[Node])
