extends Node

enum ModelType { GENERIC, VRM }

signal file_to_load_changed(file_path, file_type)
#warning-ignore:unused_signal
signal model_loaded(model_reference)
#warning-ignore:unused_signal
signal properties_applied(property_data)

###############################################################################
# Builtin functions                                                           #
###############################################################################

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func set_file_to_load(file_path: String, file_type: int) -> void:
	emit_signal("file_to_load_changed", file_path, file_type)
