class Synthesizer
  constructor: ->
    @sampleRate = 44100
    @delayLine  = new Array 100

    AudioContext = webkitAudioContext

    @context = new AudioContext
    @node    = @context.createJavaScriptNode 4096 # what do they mean?

    phaseL = 0.0
    phaseR = 0.0
    @node.onaudioprocess = (event) =>
      inputArrayL  = event.inputBuffer.getChannelData 0
      inputArrayR  = event.inputBuffer.getChannelData 1
      outputArrayL = event.outputBuffer.getChannelData 0
      outputArrayR = event.outputBuffer.getChannelData 1

      n = inputArrayL.length

      for i in [0...n]
        sampleL = Math.sin phaseL
        sampleR = Math.sin phaseR

        phaseL += TWO_PI * 440.0 / @sampleRate
        phaseR += TWO_PI * 440.0 / @sampleRate

        phaseL -= TWO_PI if phaseL > TWO_PI
        phaseR -= TWO_PI if phaseR > TWO_PI

        outputArrayL[i] = sampleL
        outputArrayR[i] = sampleR

    @node.connect @context.destination
