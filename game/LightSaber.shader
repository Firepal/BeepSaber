shader_type spatial;
render_mode unshaded;

uniform vec4 color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float is_ball : hint_range(0.0,1.0);

mat3 facecam(vec3 vector){
	vec3 a = normalize(cross(vector,vec3(0.0,0.0,1.0)));
	vec3 c = normalize(vector);
	vec3 b = cross(a,c);
	return mat3(a,b,c);
}

varying float fresnel;
void vertex(){
	vec3 cam_position = (WORLD_MATRIX[3].xyz-CAMERA_MATRIX[3].xyz)*mat3(WORLD_MATRIX);
	mat3 unlocked = facecam(cam_position);
	cam_position *= vec3(1.0,1.0,0.0);
	mat3 locked = facecam(cam_position);
	vec3 viewball = unlocked*vec3(0.0,0.0,-1.0);
	vec3 viewlocked = locked*vec3(0.0,0.0,-1.0);
	fresnel = (1.0-dot( normalize(mix(viewlocked,viewball,is_ball)) ,NORMAL))*2.0;
}

void fragment() {
	ALBEDO = color.rgb * fresnel;
}

