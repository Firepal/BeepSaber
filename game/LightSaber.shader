shader_type spatial;
render_mode unshaded;

uniform vec4 color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float is_ball : hint_range(0.0,1.0);
uniform int size;

mat3 facevec(vec3 vector){
	vec3 c = normalize(vector);
	vec3 a = normalize(cross(c,vec3(0.0,0.0,1.0)));
	vec3 b = cross(a,c);
	return mat3(a,b,c);
}
mat3 rotation3dZ(float angle) {
	float s = sin(angle);
	float c = cos(angle);

	return mat3(
		vec3(c, s, 0.0),
		vec3(-s, c, 0.0),
		vec3(0.0, 0.0, 1.0)
	);
}
varying vec3 customview;
varying vec3 pos;
void vertex(){
	mat3 rotato = rotation3dZ(TIME);
	const vec3 noisesize = vec3(1.0,1.0,0.25)*200.0;
	pos = (rotato*VERTEX)*noisesize;
	vec3 wVertex = (WORLD_MATRIX * vec4(VERTEX,1.0)).xyz;
	vec3 cam_position = (wVertex-CAMERA_MATRIX[3].xyz)*mat3(WORLD_MATRIX);
	mat3 unlocked = facevec(cam_position);
	cam_position *= vec3(1.0,1.0,0.0);
	
	mat3 locked = facevec(cam_position);
	vec3 viewball = unlocked*vec3(0.0,0.0,-1.0);
	vec3 viewlocked = locked*vec3(0.0,0.0,-1.0);
	
	vec3 view = mix(viewlocked,viewball,is_ball);
	customview = mat3(MODELVIEW_MATRIX)*view;
	float sizingfactor = float(size);
	UV.x = (UV.x*sizingfactor);
	UV.y *= 35.0*sizingfactor;
}

float random31(vec3 p3) {
	p3  = fract(p3 * .1031);
	p3 += dot(p3, p3.zyx + 31.32);
	return fract((p3.x + p3.y) * p3.z);
}

float noise3d( vec3 uvw ){
	vec3 u = fract(uvw);
	uvw = floor(uvw);
	u = smoothstep(0.95,1.0,u); // uncomment for linear
	float a = random31( uvw );
	float b = random31( uvw+vec3(1.0,0.0,0.0) );
	float c = random31( uvw+vec3(0.0,1.0,0.0) );
	float d = random31( uvw+vec3(1.0,1.0,0.0) );
	float e = random31( uvw+vec3(0.0,0.0,1.0) );
	float f = random31( uvw+vec3(1.0,0.0,1.0) );
	float g = random31( uvw+vec3(0.0,1.0,1.0) );
	float h = random31( uvw+vec3(1.0,1.0,1.0) );
	
	return mix(mix(mix( a, b, u.x),
                       mix( c, d, u.x), u.y),
                   mix(mix( e, f, u.x),
                       mix( g, h, u.x), u.y), u.z);
}

float fBm(vec3 x) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(200.0);
	const int OCTAVES = 3;
	for (int i = 0; i < OCTAVES; ++i) {
		v += a * noise3d(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

void fragment() {
//	vec2 customUV = floor( (UV*3.0) + vec2(TIME*6.0,0.0) );
//	int cool_formula = int( dot(vec2(customUV),customUV) );
//	float yes = float((cool_formula % size) )/float(size);
//	ALBEDO = mix(vec3( step(0.95,yes) )*smoothstep(1.0,0.0,-VERTEX.z), color.rgb, fresnel);
	float v = dot(NORMAL,normalize(customview));
	v = smoothstep(1.0,0.9,v);
	v = sqrt(v);
	float yes = noise3d(pos);
	ALBEDO = mix(color.rgb,vec3(1.0),(yes*0.75)+v);
}
