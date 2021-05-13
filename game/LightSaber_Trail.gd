# This script generates the saber trail with a triangle strip
# TODO:
#	UV mapping has strange interpolation (bad UV values?)
#	Last triangle is missing
extends ImmediateGeometry

onready var _base = $"../base"
onready var _tip = $"../tip"
onready var _saber = $"../"
var points = []
var max_points = 18

func _process(delta):
	clear()
	points.push_front( _saber.global_transform.translated(_get_saber_midpoint()) )
	points.resize(max_points)
	if points.size() > 0:
		var array_is_filled = points[points.size()-1] != null
		if _saber.is_extended() and array_is_filled:
			make_trail()

func _get_saber_midpoint():
	return _base.translation.linear_interpolate(_tip.translation,0.5)
	
func _get_saber_size():
	return _tip.translation.distance_to(_base.translation)*0.52

func make_trail():
	begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	var p = points
	var ps = p.size()-1
	
	for i in range(ps):
		if i == 0:
			_first_triangle(p, i, ps)
		elif i == ps-1:
			_last_triangle(p, i, ps);
		else:
			_middle_triangle(p, i, ps)
	end()

func _point_data(p,i):
	var p1 = to_local(p[i].origin)
	var p2 = to_local(p[i+1].origin)
	return [p1,p2]

func _first_triangle(p,index,size):
	var data = _point_data(p,index)
	var p1 = data[0]
	var p2 = data[1]
	
	var perp = _get_perp(p,index)
	_set_uvd( index, size )
	add_vertex( p1 + perp )
	_set_uv( index, size )
	add_vertex( p1 - perp )
	
	_set_uvd( index+1, size )
	add_vertex( p2 + perp )

func _middle_triangle(p,index,size):
	var data = _point_data(p,index)
	var p1 = data[0]
	var p2 = data[1]
	var perp = _get_perp(p,index)
	_set_uv( index, size )
	add_vertex( p1 - perp )
	
	_set_uvd( index+1, size )
	add_vertex( p2 + perp )

func _last_triangle(p,index,size):
	var data = _point_data(p,index)
	var p1 = data[0]
	var p2 = data[1]
	var perp = _get_perp(p,index)
	
	_set_uv( index, size )
	add_vertex( p1 - perp )
	
	_set_uvd( index+1, size )
	add_vertex( p2 + perp )
	_set_uv( index+1, size )
	add_vertex( p2 - perp )

func _get_perp(p,index): return p[index].basis.y*_get_saber_size()
func _uv(i,s): return float(s-i)/s
func _set_uv(i,s):	set_uv( Vector2(_uv(i,s),0.0) )
func _set_uvd(i,s):	set_uv( Vector2(_uv(i,s),1.0) )
