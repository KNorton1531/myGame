extern number timeOfDay;
extern vec2 resolution;
extern vec2 lightPosition;
extern number lightRadius;
extern number lightIntensity;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // Normalize screen coordinates based on resolution
    vec2 normalizedCoords = screen_coords / resolution;

    // Calculate distance from the light source
    float distanceToLight = length(screen_coords - lightPosition);

    // Apply attenuation based on the distance and radius
    float attenuation = clamp(1.0 - (distanceToLight / lightRadius), 0.0, 1.0);

    // Combine light intensity with attenuation
    float lightEffect = lightIntensity * attenuation;

    // Simulate day/night cycle: darkness increases at night
    float darkness = 0.4 - smoothstep(0.4, 0.6, timeOfDay);

    // Final brightness combines darkness and light effect
    float finalBrightness = max(lightEffect, darkness);

    vec4 texColor = Texel(texture, texture_coords);
    return texColor * vec4(vec3(finalBrightness), 0.4);
}
