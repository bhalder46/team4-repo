shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float lod : hint_range(0.0, 5.0) = 0.0;

void fragment() {
    // Sample the screen texture with Level of Detail (LOD)
    vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod);
    
    // Set the output color
    COLOR = color;
}

