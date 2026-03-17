shader_type spatial;
uniform sampler2D diffuse: source_color, repeat_disable;
uniform sampler2D normal_map: source_color, hint_normal;

uniform uint frame = 0;
uniform uint h_frames = 1;
uniform uint v_frames = 1;

void vertex() {
	vec2 uv_mod = 1.0 / vec2(float(h_frames), float(v_frames));
	float uv_off_x = uv_mod.x * float(frame % h_frames);
	float uv_off_y = uv_mod.y * float(frame / h_frames);
	UV = UV * uv_mod + vec2(uv_off_x, uv_off_y);
}

void fragment() {
	vec4 color = texture(diffuse, UV);
	if (color.a <= 0.0f) { // alpha scissor
		discard;
	}
	
	ALBEDO = color.rgb;
	ALPHA = color.a; // regular alpha
	NORMAL = texture(normal_map, UV).rbg;
	
}
