shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D paper_texture;

uniform float blend_strength : hint_range(0.0, 1.0) = 0.45;
uniform float contrast_boost : hint_range(0.0, 2.0) = 1.15;
uniform float saturation : hint_range(0.0, 2.0) = 0.9;
uniform vec4 new_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {

    vec4 base = texture(screen_texture, SCREEN_UV);


    base.rgb = (base.rgb - 0.5) * contrast_boost + 0.5;


    float gray = dot(base.rgb, vec3(0.299, 0.587, 0.114));
    base.rgb = mix(vec3(gray), base.rgb, saturation);

    vec4 paper = texture(paper_texture, SCREEN_UV);

    vec3 blended = mix(base.rgb, base.rgb * paper.rgb, blend_strength);

   COLOR = vec4(blended * new_color.rgb, base.a);
}
