shader_type canvas_item;

uniform float blur_amount : hint_range(0.5, 5.0, 0.1) = 1.0;
uniform float darken : hint_range(0.0, 1.0, 0.1) = 0.0; // 0.0 = no darkening, 1.0 = full black.

void fragment() {
    vec3 col = texture(TEXTURE, UV).xyz * 0.5; // Increase weight for the main sample.
    col += texture(TEXTURE, UV + vec2(blur_amount * TEXTURE_PIXEL_SIZE.x, 0.0)).xyz * 0.05;
    col += texture(TEXTURE, UV + vec2(-blur_amount * TEXTURE_PIXEL_SIZE.x, 0.0)).xyz * 0.05;
    col += texture(TEXTURE, UV + vec2(2.0 * blur_amount * TEXTURE_PIXEL_SIZE.x, 0.0)).xyz * 0.03;
    col += texture(TEXTURE, UV + vec2(-2.0 * blur_amount * TEXTURE_PIXEL_SIZE.x, 0.0)).xyz * 0.03;
    col += texture(TEXTURE, UV + vec2(3.0 * blur_amount * TEXTURE_PIXEL_SIZE.x, 0.0)).xyz * 0.02;
    col += texture(TEXTURE, UV + vec2(-3.0 * blur_amount * TEXTURE_PIXEL_SIZE.x, 0.0)).xyz * 0.02;

    col += texture(TEXTURE, UV + vec2(0.0, blur_amount * TEXTURE_PIXEL_SIZE.y)).xyz * 0.05;
    col += texture(TEXTURE, UV + vec2(0.0, -blur_amount * TEXTURE_PIXEL_SIZE.y)).xyz * 0.05;
    col += texture(TEXTURE, UV + vec2(0.0, 2.0 * blur_amount * TEXTURE_PIXEL_SIZE.y)).xyz * 0.03;
    col += texture(TEXTURE, UV + vec2(0.0, -2.0 * blur_amount * TEXTURE_PIXEL_SIZE.y)).xyz * 0.03;
    col += texture(TEXTURE, UV + vec2(0.0, 3.0 * blur_amount * TEXTURE_PIXEL_SIZE.y)).xyz * 0.02;
    col += texture(TEXTURE, UV + vec2(0.0, -3.0 * blur_amount * TEXTURE_PIXEL_SIZE.y)).xyz * 0.02;

    col *= (1.0 - darken); // Apply darkening factor.

    COLOR.xyz = col;
}
