uniform sampler2D bokeh_b;
uniform sampler2D bokeh_c;
uniform sampler2D bokeh_d;
uniform float strength = 1.0;
const vec2 blurdir = vec2( -1.0, -0.577350269189626 );
out vec4 color;

// ====

const int NUM_SAMPLES = 16;

vec3 srgb2lin(vec3 c) { return c*c; }
vec3 lin2srgb(vec3 c) { return sqrt(c); }

//note: uniform pdf rand [0;1[
float hash12n(vec2 p){
  p  = fract(p * vec2(5.3987, 5.4421));
  p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
  return fract(p.x * p.y * 95.4307);
}

void main(){
  ivec2 iResolution = textureSize(bokeh_b, 0);
  vec2 fragCoord = gl_FragCoord.xy;
  vec2 blurvec = normalize(blurdir) / iResolution.xx;
  vec2 uv = fragCoord / iResolution.xy;
    
  vec2 p0 = uv;
  vec2 p1 = uv + strength * blurvec;
  vec2 stepvec = (p1-p0) / float(NUM_SAMPLES);
  vec2 p = p0;
  p += (hash12n(uv+blurdir.x*blurdir.y)) * stepvec;
    
  vec3 sumcol = vec3(0.0);
  for (int i=0;i<NUM_SAMPLES;++i){
    sumcol += srgb2lin( texture( bokeh_b, p, -10.0 ).rgb);
    p += stepvec;
  }
  sumcol /= float(NUM_SAMPLES);
    
  vec3 s2 = srgb2lin( texture( bokeh_c, uv).rgb );
  vec3 s3 = srgb2lin( texture( bokeh_d, uv).rgb );
    
  vec3 outcol = sumcol + s2 + s3;
  color = vec4( lin2srgb(outcol), 1.0 );
}
