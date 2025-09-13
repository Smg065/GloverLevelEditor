extends Path3D
class_name PlatformPath

var platformVisualization : PathFollow3D

#func _ready() -> void:
#	platformVisualization = PathFollow3D.new()
#	platformVisualization.loop = false
#	platformVisualization.rotation_mode = PathFollow3D.ROTATION_NONE
#	platformVisualization.tilt_enabled = false

func new_point_info(pathPoint : Vector3, duration : float):
	curve.add_point(pathPoint)
	curve.set_point_tilt(curve.point_count - 1, duration)

func set_point_info(setIndex : int, pathPoint : Vector3, duration : float):
	curve.set_point_position(setIndex, pathPoint)
	curve.set_point_tilt(setIndex, duration)
