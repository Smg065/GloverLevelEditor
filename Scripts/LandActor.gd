extends MeshInstance3D
class_name LandActor

var modelRef : ModelReference

func setup_land_actor(newModelRef : ModelReference):
	modelRef = newModelRef
	mesh = modelRef.arrayMesh
