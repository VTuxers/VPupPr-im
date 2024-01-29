class_name ModelImporter

static func import_model_infer_extension(model_path: String) -> Node3D:
	if model_path.ends_with(".vrm"):
		return ModelImporter.import_model_vrm(model_path)
	elif model_path.ends_with(".gltf"):
		return ModelImporter.import_model_gltf(model_path)
	elif model_path.ends_with(".import"):
		return ModelImporter.import_model_scene(model_path)
	
	print("Can't import model \'%s\' (Unknown type)" % model_path)
	return null

static func import_model_scene(model_path: String) -> Node3D:
	print("Import scene: " + model_path)
	return load(model_path.split(".import")[0]).instantiate()

static func import_model_vrm(model_path: String) -> Node3D:
	### Load a model from a given file path. Code taken from addons/vrm/import_vrm:_import_scene()
	print("Import VRM: " + model_path)
	
	var gltf: GLTFDocument = GLTFDocument.new()
	var vrm_extensions: Array[GLTFDocumentExtension] = _register_vrm_extensions()
	
	# Load model scene
	var generated_scene = ModelImporter._import_model_gltf(model_path, gltf)
	
	_unregister_vrm_extensions(vrm_extensions)
	return generated_scene

static func import_model_gltf(model_path: String) -> Node3D:
	print("Import GLTF: " + model_path)
	var gltf: GLTFDocument = GLTFDocument.new()
	return ModelImporter._import_model_gltf(model_path, gltf)

static func _import_model_gltf(model_path: String, gltf: GLTFDocument) -> Node3D:
	var flags: int = EditorSceneFormatImporter.IMPORT_USE_NAMED_SKIN_BINDS | \
		EditorSceneFormatImporter.IMPORT_GENERATE_TANGENT_ARRAYS | \
		EditorSceneFormatImporter.IMPORT_ANIMATION
	var state: GLTFState = GLTFState.new()
	# HANDLE_BINARY_EMBED_AS_BASIS crashes on some files in 4.0 and 4.1
	state.handle_binary_image = GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED  # GLTFState.HANDLE_BINARY_EXTRACT_TEXTURES
	
	var err = gltf.append_from_file(model_path, state, flags)
	if err != OK:
		return null
	
	# Load model scene
	var generated_scene = gltf.generate_scene(state)
	return generated_scene

static func _register_vrm_extensions() -> Array[GLTFDocumentExtension]:
	### Initialize GLTF VRM extensions before loading vrm
	var extensions: Array[GLTFDocumentExtension] = []
	extensions.append(preload("res://addons/vrm/vrm_extension.gd").new())
	
	for ext in extensions:
		GLTFDocument.register_gltf_document_extension(ext, true)
	
	var secondary_extensions: Array[GLTFDocumentExtension] = []
	secondary_extensions.append(preload("res://addons/vrm/1.0/VRMC_materials_hdr_emissiveMultiplier.gd").new())
	secondary_extensions.append(preload("res://addons/vrm/1.0/VRMC_materials_mtoon.gd").new())
	secondary_extensions.append(preload("res://addons/vrm/1.0/VRMC_node_constraint.gd").new())
	secondary_extensions.append(preload("res://addons/vrm/1.0/VRMC_springBone.gd").new())
	secondary_extensions.append(preload("res://addons/vrm/1.0/VRMC_vrm.gd").new())
	
	for ext in secondary_extensions:
		GLTFDocument.register_gltf_document_extension(ext)
	
	return extensions + secondary_extensions

static func _unregister_vrm_extensions(vrm_extensions: Array[GLTFDocumentExtension]):
	### Unregister GLTF VRM extensions after loading vrm
	vrm_extensions.reverse()
	for ext in vrm_extensions:
		GLTFDocument.unregister_gltf_document_extension(ext)
