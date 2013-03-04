uniform sampler2D texture ;
//uniform sampler2DRect texture_rect ;

uniform float width;
uniform float height;
uniform float alpha;

//uniform int npot;

void main(void)
{
	vec4 texel;
	vec4 endtexel;

	vec2 u = vec2(width,height);

	vec4 newtexel;
	float num;
	vec2 texC = gl_TexCoord[0].st;

#if 0  // double loop ...
	ivec2 lx = vec2(-2,2);
	ivec2 ly = vec2(-2,2);
	int i,j;
	for (i = lx[0]; i <= lx[1]; i = i+1)
	{
		for (j = ly[0]; j <= ly[1]; j = j+1)
		{
			vec2 tmp = gl_TexCoord[0].st
				+ vec2(i*u.x,j*u.y);
			// No test slow down to much!
			//if (tmp.x >= 0.0 && tmp.x <= 1.0 &&
			//    tmp.y >= 0.0 && tmp.y <= 1.0)
			newtexel = newtexel +
				texture2D(
					texture,
					gl_TexCoord[0].st + vec2(i*u.x,j*u.y));
			num++;
		}
	}
#else // double loop ...

#if 0
	newtexel = newtexel + texture2D(texture, texC + vec2(-2.0*u.x,-2.0*u.y));
	//num++;
#endif
	newtexel = newtexel + texture2D(texture, texC + vec2(-2.0*u.x,-1.0*u.y));
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(-2.0*u.x,0));
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(-2.0*u.x,1.0*u.y));
	//num++;
#if 0
	newtexel = newtexel + texture2D(texture, texC + vec2(-2.0*u.x,2.0*u.y));
	//num++;	
#endif

	newtexel = newtexel + texture2D(texture, texC + vec2(-1.0*u.x,-2.0*u.y));
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(-1.0*u.x,-1.0*u.y));
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(-1.0*u.x,0));
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(-1.0*u.x,1.0*u.y));
	//num++;	
	newtexel = newtexel + texture2D(texture, texC + vec2(-1.0*u.x,2.0*u.y));
	//num++;

	newtexel = newtexel + texture2D(texture, texC + vec2(0.0,-2.0*u.y));
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(0.0,-1.0*u.y));
	//num++;
	// no factor
	newtexel =  newtexel + texture2D(texture, texC);;
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(0.0,1.0*u.y));
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(0,2.0*u.y));
	//num++;

	newtexel = newtexel + texture2D(texture, texC + vec2(u.x,-2.0*u.y));
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(u.x,-1.0*u.y));
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(u.x,0.0));
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(u.x,1.0*u.y));
	//num++;	
	newtexel = newtexel + texture2D(texture, texC + vec2(u.x,2.0*u.y));
	//num++;	

#if 0
	newtexel = newtexel + texture2D(texture, texC + vec2(2.0*u.x,-2.0*u.y));
	//num++;
#endif
	newtexel = newtexel + texture2D(texture, texC + vec2(2.0*u.x,-1.0*u.y));
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(2.0*u.x,0.0));
	//num++;
	newtexel = newtexel + texture2D(texture, texC + vec2(2.0*u.x,1.0*u.y));
	//num++;
#if 0
	newtexel = newtexel + texture2D(texture, texC + vec2(2.0*u.x,2.0*u.y));
	//num++;
#endif
	
	num = 21.0;

#endif  // double loop

	endtexel  = newtexel/num;
	endtexel.a = alpha;
	gl_FragColor = endtexel;
}
