shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec3 colour: source_color = vec3(1);
uniform float curve_depth = 0.02;

void vertex() {
	float x = abs(0.5 - UV.x) * 2.0;
	VERTEX.z -= (x * x * x) * curve_depth;
}

void fragment() {
	float x = sin(UV.x * PI);
	ALPHA = step(UV.y, x) * step(x, UV.y * 2.0);
	ALBEDO = colour;
}
