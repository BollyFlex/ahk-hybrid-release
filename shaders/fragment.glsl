precision mediump float;

const vec4 			cDimLightFogColour = vec4( 0.0, 0.0, 0.0, 1.0 );
const float			cFullBrightIllum = 1.0;
const float         cBaseBrightness = 1.5; // non-configurable scaling value
const float			cBrightnessMult = 1.0; // make this a user option

uniform sampler2D 	uSampler;
uniform float       uFramePadding; // wrapped tex coords are "trimmed" by this value inside the frame coords, to prevent texels from outside the frame being sampled due to rounding errors
uniform float       uMinDarkScalingMult;
uniform vec4        uFogColour;
uniform float       uFogDensity;
uniform float       uDimLightFogDensity;

varying vec2 		vTexCoord;
varying float 		vLightLevel;
varying float		vFullBright;
varying float       vFrameLeft;
varying float       vFrameTop;
varying float       vFrameWidth;
varying float       vFrameHeight;


void main(void) {

    // TODO - move any portions of this calculation into vertex shader if poss.
    
    // Formula for atlas wrapping is: wrappedCoord = frameOffset + mod( texCoord - frameOffset, frameWidth )
    float wrappedTexCoordX = vFrameLeft + mod( vTexCoord.x - vFrameLeft, vFrameWidth ); // NOTE - only needed for atlas texture wrapping (make separate shader for non-wrapping mode eg. sprites)
    float wrappedTexCoordY = vFrameTop - vFrameHeight + mod( vTexCoord.y - vFrameTop - vFrameHeight, vFrameHeight ); //vFrameTop - vFrameHeight + mod( vTexCoord.y, vFrameHeight ); // NOTE - only needed for atlas texture wrapping (make separate shader for non-wrapping mode eg. sprites)

    wrappedTexCoordX = clamp( wrappedTexCoordX, vFrameLeft + uFramePadding, vFrameLeft + vFrameWidth - uFramePadding );
    wrappedTexCoordY = clamp( wrappedTexCoordY, vFrameTop - vFrameHeight + uFramePadding, vFrameTop - vFrameHeight + vFrameHeight - uFramePadding );

    vec4 texColour = texture2D( uSampler, vec2( wrappedTexCoordX, wrappedTexCoordY ) );

    if( texColour.a < 0.5 ){
        discard;
    }

    float depth = gl_FragCoord.z / gl_FragCoord.w; // fragment Z depth - useful for distance effects
    float illum = vLightLevel;

    if( vFullBright != 0.0 && illum < cFullBrightIllum ){

    	illum = cFullBrightIllum;
    }

    texColour = texColour * vec4( illum, illum, illum, 1.0 );

    // Diminished lighting does not effect fullbrights
    if( vFullBright == 0.0 ){

    	// Diminished lighting using fog
    	float invLightLevel = clamp( 1.0 - vLightLevel, uMinDarkScalingMult, 1.0 );
    	float biasedDimFogDensity = clamp( uDimLightFogDensity * invLightLevel, 0.0, 1.0 );
    	float dimFogFactor = clamp( 1.0 / exp( depth * biasedDimFogDensity ), 0.0, 1.0 ); // exponential fog

    	texColour = mix( cDimLightFogColour, texColour, vec4( dimFogFactor, dimFogFactor, dimFogFactor, 1.0 ) );
    }

    // Atmospheric fog
    float fogFactor = clamp( 1.0 / exp( depth * uFogDensity ), 0.0, 1.0 ); // exponential fog
    texColour = mix( uFogColour, texColour, vec4( fogFactor, fogFactor, fogFactor, 1.0 ) );

    // Brightness scaling
    float brightness = cBaseBrightness * cBrightnessMult;
    texColour = texColour * vec4( brightness, brightness, brightness, 1.0 );

    // Final fragment colour
    gl_FragColor = texColour;
   // gl_FragColor = vec4( 1.0, 0.0, 1.0, 1.0 );
}
