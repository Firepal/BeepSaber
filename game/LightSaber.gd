# The lightsaber logic is mostly contained in the BeepSaber_Game.gd
# here I only track the extended/sheethed state and provide helper functions to
# trigger the necessary animations
extends Area

# store the saber material in a variable so the main game can set the color on initialize
onready var _saber_mat : ShaderMaterial = $LightSaber_Mesh.mesh.surface_get_material(0);
onready var _glow_mat : ShaderMaterial = $Glow_Mesh.mesh.surface_get_material(0);
onready var _anim := $AnimationPlayer;

# the type of note this saber can cut (set in the game main)
var type = 0;

onready var imm_geo = $ImmediateGeometry

func show():
	if (!is_extended()):
		_anim.play("Show");


func is_extended():
	return $LightSaber_Mesh.translation.y > 0.1;


func hide():
	# This check makes sure that we are not already in the hidden state
	# (where we translated the light saber to the hilt) to avoid playing it back
	# again from the fully extended light saber position
	if (is_extended() and _anim.current_animation != "QuickHide"):
		_anim.play("Hide");

func set_thickness(value):
	$LightSaber_Mesh.scale.x = value
	$LightSaber_Mesh.scale.y = value

func set_tail_size(size=18):
	imm_geo.max_points = size

func set_color(color):
	_saber_mat.set_shader_param("color", color);
	_glow_mat.set_shader_param("color", color);
	imm_geo.material_override.set_shader_param("color", color);

func _ready():
	imm_geo.material_override = imm_geo.material_override.duplicate()
	_anim.play("QuickHide");
	remove_child(imm_geo)
	get_tree().get_root().add_child(imm_geo)

func _process(delta):
	if is_extended():
		# Check floor collision for burn mark
		$RayCast.force_raycast_update()
		if $RayCast.is_colliding():
			var raycoli = $RayCast.get_collider()
			if raycoli in get_tree().get_nodes_in_group("floor"):
				var colipoint = $RayCast.get_collision_point()
				raycoli.burn_mark(colipoint,type)
		
	else:
		imm_geo.clear()
	
func get_tip():
	return $tip.global_transform.origin
