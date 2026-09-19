class_name SaveFileManager extends FileDialog

@export var tile_map : GameTileMap

func _ready() -> void:
	file_selected.connect(FileSelected)

func FileSelected(file_name):
	var save = file_mode == 4
	if save:
		tile_map.save_map(file_name)
	else:
		tile_map.load_map(file_name)

func RequestOpenGameLevelMapFile():
	if visible: return
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	popup_centered_clamped()

func RequestSaveGameLevelMapFile():
	if visible: return
	file_mode = FileDialog.FILE_MODE_SAVE_FILE
	popup_centered_clamped()
