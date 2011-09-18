# Constants
PI          = Math.PI
TWO_PI      = Math.PI * 2
HALF_PI     = Math.PI / 2
SMALL       = 1 / 4294967295
SAMPLE_RATE = 44100

# Arrays
window.Float32Array = Float32Array    or
                      WebGLFloatArray or
                      Array

# Helper methods
Helper =
  clip: (value) ->
    if value > 1
      1
    if value < -1
      -1
    value
