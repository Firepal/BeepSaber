shader_type spatial;
render_mode unshaded;

uniform vec4 color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float is_ball : hint_range(0.0,1.0);
uniform bool classic;
uniform int size;

mat3 facecam(vec3 vector){
	vec3 a = normalize(cross(vector,vec3(0.0,0.0,1.0)));
	vec3 c = normalize(vector);
	vec3 b = cross(a,c);
	return mat3(a,b,c);
}

varying vec3 customview;
void vertex(){
	vec3 wVertex = (WORLD_MATRIX * vec4(VERTEX,1.0)).xyz;
	vec3 cam_position = (wVertex-CAMERA_MATRIX[3].xyz)*mat3(WORLD_MATRIX);
	mat3 unlocked = facecam(cam_position);
	cam_position *= vec3(1.0,1.0,0.0);
	
	mat3 locked = facecam(cam_position);
	vec3 viewball = unlocked*vec3(0.0,0.0,-1.0);
	vec3 viewlocked = locked*vec3(0.0,0.0,-1.0);
	
	vec3 view = mix(viewlocked,viewball,is_ball);
	customview = normalize(mat3(MODELVIEW_MATRIX)*view);
	float sizingfactor = float(size);
	UV.x = (UV.x*sizingfactor);
	UV.y *= 35.0*sizingfactor;
}

void fragment() {
	vec2 customUV = floor( (UV*3.0) + vec2(TIME*6.0,0.0) );
	int cool_formula = int( dot(vec2(customUV),customUV) );
	float yes = float((cool_formula % size) )/float(size);
//	ALBEDO = mix(vec3( step(0.95,yes) )*smoothstep(1.0,0.0,-VERTEX.z), color.rgb, fresnel);
	float v = dot(NORMAL,customview);
	v = smoothstep(1.0,0.85,v);
	ALBEDO = mix(color.rgb,vec3(1.0),v+(yes));
}
