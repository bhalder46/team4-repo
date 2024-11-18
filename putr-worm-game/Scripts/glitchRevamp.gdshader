shader_type canvas_item;

uniform float shake_power = 0.02;                        // Strength of shake
uniform float shake_rate : hint_range(0.0, 1.0) = 0.4;   // Frequency of glitch
uniform float shake_speed = 8.0;                         // Speed of shake
uniform float shake_block_size = 15.0;                   // Block size
uniform float shake_color_rate : hint_range(0.0, 1.0) = 0.005; // Color separation
uniform float glitch_duration = 0.5;                     // Duration of glitch in seconds
uniform float glitch_start_time = 0.0;                   // Start time for the glitch

uniform sampler2D screen_texture : hint_screen_texture;

// Random function for glitching
float random(float seed) {
    return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

void fragment() {
    // Calculate elapsed time since glitch start
    float elapsed_time = TIME - glitch_start_time;

    // Enable glitch only if within the glitch duration
    float enable_glitch = float(elapsed_time <= glitch_duration);

    // Random shift for glitch effect, controlled by shake_rate and shake_speed
    float enable_shift = float(random(trunc(TIME * shake_speed)) < shake_rate) * enable_glitch;

    vec2 fixed_uv = SCREEN_UV;
    fixed_uv.x += (random((trunc(SCREEN_UV.y * shake_block_size) / shake_block_size) + TIME) - 0.5) * shake_power * enable_shift;

    vec4 pixel_color = textureLod(screen_texture, fixed_uv, 0.0);

    // Color channel separation
    pixel_color.r = mix(pixel_color.r, textureLod(screen_texture, fixed_uv + vec2(shake_color_rate, 0.0), 0.0).r, enable_shift);
    pixel_color.b = mix(pixel_color.b, textureLod(screen_texture, fixed_uv + vec2(-shake_color_rate, 0.0), 0.0).b, enable_shift);

    COLOR = pixel_color;
}
