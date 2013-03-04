uniform sampler2D texture ;
// uniform sampler2DRect texture ;

//uniform float width;
//uniform float height;

uniform float alpha;
uniform float nbr_anim_step;
uniform float current_step;

void main(void) {
	vec4 texel = gl_Color * texture2D(texture, gl_TexCoord[0].st) ;
	// vec4 texel = gl_Color * texture2DRect(texture, gl_TexCoord[0].st) ;

#if 1
	// dimmed
	vec4 endtexel = texel.rgba * vec4(0.85,0.85,0.85, 1.0) ;
#elif 0
	// color invert
	vec4 endtexel = vec4(1.0-texel.r, 1.0-texel.g, 1.0-texel.b, texel.a);
#elif 0
	// grayscale
	vec3 scaledColor = texel.rgb * vec3(0.30, 0.59, 0.11) ;
	float luminance = scaledColor.r + scaledColor.g + scaledColor.b ;
	vec4 endtexel = vec4(luminance, luminance, luminance, texel.a) ;
#elif 0
	// grayscale invert
	vec3 scaledColor = texel.rgb * vec3(0.30, 0.59, 0.11) ;
	float luminance = scaledColor.r + scaledColor.g + scaledColor.b ;
	vec4 endtexel = vec4(1.0-luminance, 1.0-luminance, 1.0-luminance, texel.a) ;
#elif 0
	// sepia
	vec3 scaledColor = texel.rgb * vec3(0.30, 0.59, 0.11) ;
	float luminance = scaledColor.r + scaledColor.g + scaledColor.b ;
	vec4 endtexel = vec4(luminance+0.1912, luminance-0.0544, luminance-0.2210, texel.a);
#endif

	if (nbr_anim_step != 0.0)
	  gl_FragColor = mix(texel,endtexel,current_step/nbr_anim_step) ;
	else
		gl_FragColor = endtexel;
}
