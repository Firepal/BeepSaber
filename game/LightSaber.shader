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

varying float fresnel;
void vertex(){
	vec3 wVertex = (WORLD_MATRIX * vec4(VERTEX,1.0)).xyz;
	vec3 cam_position = (wVertex-CAMERA_MATRIX[3].xyz)*mat3(WORLD_MATRIX);
	mat3 unlocked = facecam(cam_position);
	cam_position *= vec3(1.0,1.0,0.0);
	
	mat3 locked = facecam(cam_position);
	vec3 viewball = unlocked*vec3(0.0,0.0,-1.0);
	vec3 viewlocked = locked*vec3(0.0,0.0,-1.0);
	
	if (classic){
	fresnel = 1.0-dot(viewball, NORMAL);
	fresnel = smoothstep(0.0, 0.3, fresnel);
	} else {
	vec3 customview = mix(viewlocked,viewball,is_ball);
	fresnel = pow(1.6-dot(normalize(customview), NORMAL),3.0);
	}
	float sizingfactor = float(size);
	UV.x = (UV.x*sizingfactor);
	UV.y *= 35.0*sizingfactor;
}

void fragment() {
	vec2 customUV = floor( (UV*10.0) + vec2(TIME*8.0,0.0) );
	int cool_formula = int( dot(vec2(customUV*1.4),customUV) );
	float yes = float((cool_formula % size) )/float(size-1);
	ALBEDO = mix(vec3( step(0.95,yes) )*smoothstep(1.0,0.0,-VERTEX.z), color.rgb, fresnel);
}
