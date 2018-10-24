uniform sampler2D previous_pass;
uniform float strength = 1.0;
uniform vec2 blurdir = vec2( -1.0, -0.577350269189626 );
out vec4 color;

// ====

const float blurdist_px = 32.0;
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
  ivec2 iResolution = textureSize(previous_pass, 0);
  vec2 fragCoord = gl_FragCoord.xy;
  vec2 blurvec = normalize(blurdir) / iResolution.xy;
  vec2 uv = fragCoord / iResolution.xy;
    
  vec2 p0 = uv;
  vec2 p1 = uv + strength * blurvec;
  vec2 stepvec = (p1-p0) / float(NUM_SAMPLES);
  vec2 p = p0;
  p += (hash12n(uv+blurdir.x*blurdir.y)) * stepvec;
    
  vec3 sumcol = vec3(0.0);
  for (int i=0;i<NUM_SAMPLES;++i){
    sumcol += srgb2lin( texture( previous_pass, p, -10.0 ).rgb);
    p += stepvec;
  }
  sumcol /= float(NUM_SAMPLES);
    
  color = vec4( lin2srgb(sumcol), 1.0 );
}
