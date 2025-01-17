shader_type canvas_item;

uniform int Time = 0;
uniform vec3 Add: source_color = vec3(0,0,0);
uniform vec3 Mul: source_color = vec3(256,256,256);
uniform vec4 SinAdd: source_color = vec4(0,0,0,1);
uniform bool InvertAll = false;
uniform int ColorScale: hint_range(0, 256) = 256;

void fragment() {
	vec3 color = texture(TEXTURE, UV).rgb;
	float gray = (color.r + color.g + color.b) / 3.0;
	vec3 grayScale = vec3(gray);
	vec3 finalGray = mix(grayScale, color, float(ColorScale) / 256.0);
	if (InvertAll) {
		finalGray = vec3(1.0) - finalGray;
	}
	float sinFactor = sin(2.0 * PI * float(Time) / (SinAdd.a * 4.0));
	vec3 sinColor = vec3(
		(Add.r / 256.0 + SinAdd.r / 256.0 * sinFactor),
		(Add.g / 256.0 + SinAdd.g / 256.0 * sinFactor),
		(Add.b / 256.0 + SinAdd.b / 256.0 * sinFactor)
	);
	vec3 finalColor = (finalGray + sinColor) * (Mul / 256.0);
	COLOR.rgb = finalColor;
}