shader_type canvas_item;

// Vibration intensity
uniform float shake_power = 0.03;
// Vibration frequency
uniform float shake_rate : hint_range(0.0, 1.0) = 0.2;
// Vibration speed
uniform float shake_speed = 5.0;
// Vibration block size
uniform float shake_block_size = 30.5;
// Screen texture
uniform sampler2D screen_texture : hint_screen_texture;

// Random function for generating pseudorandom numbers
float random(float seed) {
    return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

void fragment() {
    // Determine if the current frame will apply a shift
    float enable_shift = float(
        random(trunc(TIME * shake_speed)) < shake_rate
    );

    // Adjust UV coordinates for the glitch effect
    vec2 fixed_uv = SCREEN_UV;
    fixed_uv.x += (
        random(
            (trunc(SCREEN_UV.y * shake_block_size) / shake_block_size) + TIME
        ) - 0.5
    ) * shake_power * enable_shift;

    // Fetch the color from the distorted UV coordinates
    vec4 pixel_color = textureLod(screen_texture, fixed_uv, 0.0);

    // Convert the color to grayscale
    float grayscale = dot(pixel_color.rgb, vec3(0.299, 0.587, 0.114));

    // Apply the grayscale value with the glitch effect
    COLOR = vec4(vec3(grayscale), pixel_color.a);
}
