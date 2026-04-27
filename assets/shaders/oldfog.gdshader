shader_type spatial;

render_mode unshaded, cull_disabled, depth_prepass_alpha;

uniform sampler2D noise_tex;
uniform float speed = 0.05;
uniform float opacity = 0.3;

void fragment() {
    vec2 uv = UV;
    uv.x += TIME * speed;

    float n = texture(noise_tex, uv).r;

    ALBEDO = vec3(0.8, 0.8, 0.8);
    ALPHA = n * opacity;
	
	float depth = length(VERTEX);
	float fade = clamp((30.0 - depth) / 30.0, 0.0, 1.0);
	ALPHA *= fade;
}