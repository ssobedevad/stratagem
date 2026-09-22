class_name SaveFileManager extends FileDialog

@export var tile_map : GameTileMap
@export var camera_movement : CameraMovement

func _ready() -> void:
	file_selected.connect(FileSelected)

func _process(delta: float) -> void:
	camera_movement.paused = visible

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
