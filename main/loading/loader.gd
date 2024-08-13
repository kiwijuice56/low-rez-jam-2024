class_name Loader extends CanvasLayer

const cached_path: String = "res://main/loading/cache.tres"

@export var panel_scene: PackedScene

var cache: Cache 

func _ready() -> void:
	if not ResourceLoader.exists(cached_path):
		cache = Cache.new()
		get_all_scenes("res://main")
		ResourceSaver.save(cache, cached_path)
	
	for scene_path in ResourceLoader.load(cached_path).paths:
		load_scene(scene_path)
	
	# not sure of another way to ensure shader/particles are cached;
	# maybe will not work for larger projects
	await get_tree().create_timer(1.0).timeout
	for child in get_children():
		child.queue_free()

func get_all_scenes(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	for sub_dir in dir.get_directories():
		get_all_scenes(path + "/" + sub_dir)
	for file in dir.get_files():
		if file.contains(".tscn"):
			var actual_name: String = file.split(".")[0]
			if load_scene(path + "/" + actual_name + ".tscn"):
				cache.paths.append(path + "/" + actual_name + ".tscn")

func load_scene(path: String) -> bool:
	var root: Node = load(path).instantiate()
	var stack: Array[Node] = [root]
	var to_cache: bool = false
	while len(stack) > 0:
		var node: Node = stack.pop_back()
		if node is CanvasItem and node.material:
			var material_rect: ColorRect = panel_scene.instantiate()
			material_rect.material = node.material
			%GridContainer.add_child(material_rect)
			to_cache = true
		if node is CPUParticles2D:
			node.owner = null
			node.get_parent().remove_child(node)
			add_child(node)
			node.emitting = true
			to_cache = true
			
		stack.append_array(node.get_children() as Array[Node])
	return to_cache
