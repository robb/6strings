class Synthesizer
  constructor: ->
    AudioContext = webkitAudioContext # TODO: Add other browser if supported

    @context = new AudioContext
    @node    = @context.createJavaScriptNode 1024, 0, 2

    @strings = for i in [0..6]
       new Synthesizer.String

    @equalizer = new ThreeBandEqualizer 400, 2000
    @equalizer.lowGain  = 1.2
    @equalizer.midGain  = 1.5
    @equalizer.highGain = 0.8

    @node.onaudioprocess = (event) =>
      # Buffers
      outputArrayL = event.outputBuffer.getChannelData 0
      outputArrayR = event.outputBuffer.getChannelData 1

      for frame in [0..outputArrayL.length]
        channel = 0

        for string in @strings
          sample = string.process()

          # sum
          channel += sample / 8

        # Master EQ
        channel =  @equalizer.apply channel

        outputArrayL[frame] = channel
        outputArrayR[frame] = channel

    @node.connect @context.destination

class Synthesizer.String
  constructor: (pitch = 12) ->
    @setPitch pitch

    @lowpass   = new Lowpass
    @pluck     = 0
    @n         = 0

  setPitch: (pitch) ->
    # Determine the desired fundamental frequency of the string.
    # Assuming equal temper, concert pitch of 440 Hz.
    Hz = 55.0 * Math.pow(2, pitch / 12)

    # Since we know the samplerate, we can calculate the desired closed-
    # loop-length.
    loopLength = SAMPLE_RATE / Hz

    # But, since we've alrady got half a sample delay from the fixed
    # lowpass filter, we can already subtract a half a sample.
    loopLength -= 0.5
    @L = Math.floor loopLength

    maxlength = 1
    maxlength <<= 1 while maxlength <= @L

    unless @delayline
      @delayline    = new Float32Array maxlength
      @delayline[i] = 0 for i in [0..maxlength]

    @mask    = maxlength - 1

  process: (sample = 0) ->
    # ## Excitation
    sample += Math.random() if --@pluck > 0

    # ## Karplus-Strong
    # Add output from L samples ago.
    sample += @delayline[(@n - @L) & @mask]
    # clip
    sample = Helper.clip sample
    # apply low pass filter
    sample = @lowpass.apply sample
    # feed back into delay line
    @delayline[@n++ & @mask] = sample

    sample
