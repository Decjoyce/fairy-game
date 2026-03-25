shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform vec4 new_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
   vec4 base = texture(screen_texture, SCREEN_UV);
   COLOR = vec4(new_color.rgb, new_color.a);
}
