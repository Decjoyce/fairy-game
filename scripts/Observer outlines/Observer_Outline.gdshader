// ref : https://godotshaders.com/shader/sprite3d-outline-working-billboard/ but they were in chinese so i addapted a bit to our use
// Outline + Fade
shader_type spatial;
render_mode unshaded, blend_mix, depth_prepass_alpha, cull_disabled, specular_disabled;

uniform sampler2D sprite_texture : source_color, filter_nearest;
uniform bool enable_billboard = true;
uniform bool enable_outline = true;

// Pixel Outline Parameters
uniform vec4 simple_outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float simple_outline_width : hint_range(0, 10) = 1.0;

// Flicker Control Parameters
uniform float flash_speed : hint_range(0.1, 10.0) = 5.0;
uniform float flash_min_alpha : hint_range(0.0, 1.0) = 0.2;
uniform float flash_max_alpha : hint_range(0.0, 1.0) = 0.8;

void vertex() {
    if (enable_billboard) {
        vec3 world_origin = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
        float scale_x = length(MODEL_MATRIX[0].xyz);
        float scale_y = length(MODEL_MATRIX[1].xyz);
        vec3 cam_right = normalize(INV_VIEW_MATRIX[0].xyz);
        vec3 cam_up    = normalize(INV_VIEW_MATRIX[1].xyz);
        vec2 local = VERTEX.xy;
        vec3 world_billboard = world_origin
            + cam_right * local.x * scale_x
            + cam_up    * local.y * scale_y;
        POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world_billboard, 1.0);
    } else {
        POSITION = PROJECTION_MATRIX * VIEW_MATRIX * (MODEL_MATRIX * vec4(VERTEX, 1.0));
    }
}

void fragment() {
    vec4 col = texture(sprite_texture, UV);

    // fully transparent by default
    ALPHA = 0.0;

    if (enable_outline) {
        // Simple Pixel Outline + Fade Mode
        vec2 pixel_size = simple_outline_width / vec2(textureSize(sprite_texture, 0));

        // 8-Direction Sampling (smoother result)
        float max_alpha = 0.0;
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                if (x == 0 && y == 0) continue; // Skip the center point
                vec2 offset = vec2(float(x), float(y)) * pixel_size;
                float sample_alpha = texture(sprite_texture, UV + offset).a;
                max_alpha = max(max_alpha, sample_alpha);
            }
        }

        //the flicker factor (smoothly varying between 0 and 1)
        float flash_factor = (sin(TIME * flash_speed * 3.14159) + 1.0) * 0.5;
        float flash_alpha = mix(flash_min_alpha, flash_max_alpha, flash_factor);

        // Show only the outlined area; do not show the content in the center
        if (col.a < 0.99 && max_alpha > 0.01) {
            // Outline Area (Apply Fade)
            ALBEDO = simple_outline_color.rgb;
            ALPHA = simple_outline_color.a * flash_alpha; // Only the outline flickers
        } else {
            // The central area remains completely transparent
            ALPHA = 0.0;
        }

    } else {
        // Display the original texture when stroke is disabled
        ALBEDO = col.rgb;
        ALPHA = col.a;
    }
}
