shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

float circle(vec2 pos) {
	return length(pos) - 0.50;
}

void fragment() {
	float ratio = 15.0 / 30.0;
	vec2 adjusted_uv = vec2(UV.x, UV.y * ratio);
	vec2 scaling = fract(adjusted_uv * 40.0);
	//ALBEDO = vec3(fract(UV.x), fract(UV.y), 0);
	//float c = circle(adjusted_uv);
	//ALBEDO = vec3(c);
	ALBEDO = vec3(scaling, 0.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
