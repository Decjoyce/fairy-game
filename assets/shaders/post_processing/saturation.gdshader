shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float saturation : hint_range(0.0, 2.0) = 0.9;

void fragment() {
vec4 base = texture(screen_texture, SCREEN_UV);

float gray = dot(base.rgb, vec3(0.299, 0.587, 0.114));
base.rgb = mix(vec3(gray), base.rgb, saturation);

COLOR = vec4(base.rgb, base.a);
}
