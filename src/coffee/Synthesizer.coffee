clip = (value) ->
  if value > 1
    1
  if value < -1
    -1
  value

class Synthesizer
  constructor: ->
    AudioContext = webkitAudioContext # TODO: Add other browser if supported

    @context = new AudioContext
    @node    = @context.createJavaScriptNode 512 # what do they mean?

    @strings = for i in [0..6]
      new Synthesizer.String i

    @node.onaudioprocess = (event) =>
      # Buffers
      outputArrayL = event.outputBuffer.getChannelData 0
      outputArrayR = event.outputBuffer.getChannelData 1

      for frame in [0..outputArrayL.length]
        channels = [0, 0]

        for string in @strings
          sample = string.process()

          # sum
          channels[0] += sample / 8
          channels[1] += sample / 8

        # Clip again
        channels[0] =  clip channels[0]
        channels[1] =  clip channels[1]

        outputArrayL[frame] = channels[0]
        outputArrayR[frame] = channels[1]

    @node.connect @context.destination

class Synthesizer.Lowpass
  constructor: (gain = 0.995) ->
    @gain     = gain / 2
    @previous = 0

  apply: (sample) ->
    result    = @gain * (sample + @previous)
    @previous = sample

    result

class Synthesizer.String
  constructor: (pitch, @samplerate = 44100) ->
    @setPitch pitch

    @pluck   = 0
    @n       = 0
    @lowpass = new Synthesizer.Lowpass

  setPitch: (pitch) ->
    # Determine the desired fundamental frequency of the string.
    # Assuming equal temper, concert pitch of 440 Hz.
    Hz = 55.0 * Math.pow(2, pitch / 12)

    # Since we know the samplerate, we can calculate the desired closed-
    # loop-length.
    loopLength = @samplerate / Hz

    # But, since we've alrady got half a sample delay from the fixed
    # lowpass filter, we can already subtract a half a sample.
    loopLength -= 0.5
    @L = Math.floor loopLength

    maxlength = 1
    maxlength <<= 1 while maxlength <= @L

    unless @delayline
      # TODO: use typed array if available
      @delayline    = new Array maxlength
      @delayline[i] = 0 for i in [0..maxlength]

    @mask    = maxlength - 1

  process: ->
    sample = 0

    # ## Excitation
    sample += clip Math.random() if --@pluck > 0

    # ## Karplus-Strong
    # Add output from L samples ago.
    sample += @delayline[(@n - @L) & @mask]
    # clip
    sample = clip sample
    # apply low pass filter
    sample = @lowpass.apply sample
    # feed back into delay line
    @delayline[@n++ & @mask] = sample

    sample
