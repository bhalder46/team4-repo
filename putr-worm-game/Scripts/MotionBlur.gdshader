shader_type canvas_item;

uniform vec2 size;
uniform int samples = 0;

vec4 getPixel(sampler2D tex, vec2 uv, vec2 offset) {
	return texture(tex, uv + offset);
}

void fragment() {
	vec4 color = vec4(0.0);
	for (int x = -samples; x < 100; x++) {
		for (int y = -samples; y < 100; y++) {
			color += getPixel(TEXTURE, UV, vec2(float(x) * size.x, float(y) * size.y));

			if (y > samples) {
				break;
			}
		}
		if (x > samples) {
			break;
		}
	}
	if (samples == 0) {
		COLOR = getPixel(TEXTURE, UV, vec2(0.0, 0.0));
	} else {
		COLOR = color / float((samples * 2 + 1) * (samples * 2 + 1) - 1) + getPixel(TEXTURE, UV, vec2(0.0, 0.0));
	}
}