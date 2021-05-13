extends RigidBody

onready var _meshinstance = get_child(1)
onready var _mat = _meshinstance.material_override

const total_seconds = 0.7
var lifetime = total_seconds

func _process(delta):
	lifetime -= delta;
	if lifetime <= 0.0:
		queue_free()
		return
	var f = lifetime/total_seconds
	_mat.set_shader_param("cut_vanish",(1.0-f)*0.4)
	
	f = ease(f,0.1)
	_meshinstance.scale = Vector3(f, f, f)
