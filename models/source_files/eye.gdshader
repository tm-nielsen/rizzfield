shader_type spatial;
render_mode unshaded;

uniform vec4 iris_colour: source_color = vec4(1);
uniform vec4 pupil_colour: source_color = vec4(vec3(0), 1);
uniform float eye_width: hint_range(0.0, 1.0) = 1;
uniform float eye_height: hint_range(0.0, 1.0) = 1;
uniform float pupil_size: hint_range(0.0, 1.0) = 0.2;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
        INV_VIEW_MATRIX[0],
        INV_VIEW_MATRIX[1],
        INV_VIEW_MATRIX[2],
        MODEL_MATRIX[3]
    );
}

void fragment() {
	vec2 p = 2.0 * (UV - vec2(0.5));
	float pupil_r = p.x * p.x + p.y * p.y;
	
	p.y = abs(abs(p.y) + 1.0 - eye_height);
	p.x = abs(abs(p.x) + 1.0 - eye_width);
	float border_r = p.x * p.x + p.y * p.y;
	
	vec4 col = mix(iris_colour, pupil_colour, step(pupil_r, pupil_size * pupil_size));
	ALPHA = col.a * step(border_r, 1.0);
	ALBEDO = col.rgb;
}
