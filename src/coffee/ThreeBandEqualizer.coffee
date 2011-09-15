class ThreeBandEqualizer extends Filter
  constructor: (low = 400, high = 4000, @lowGain = 1, @midGain = 1, @highGain = 1) ->
    @f1 = [0, 0, 0, 0]
    @f2 = [0, 0, 0, 0]

    @sdm = [0, 0, 0]

    @lowFrequency  = 2 * Math.sin(PI * (low  / SAMPLE_RATE))
    @highFrequency = 2 * Math.sin(PI * (high / SAMPLE_RATE))

  setParameters: ({low, high, gain}) ->
    @lowFrequency  = 2 * Math.sin(PI * (low  / SAMPLE_RATE)) if low
    @highFrequency = 2 * Math.sin(PI * (high / SAMPLE_RATE)) if high

    [@lowGain, @midGain, @highGain] = gain if gain

  apply: (input) ->
    @f1[0] += (@lowFrequency * (input  - @f1[0])) + SMALL
    @f1[1] += (@lowFrequency * (@f1[0] - @f1[1]))
    @f1[2] += (@lowFrequency * (@f1[1] - @f1[2]))
    @f1[3] += (@lowFrequency * (@f1[2] - @f1[3]))

    l = @f1[3]

    @f2[0] += (@highFrequency * (input  - @f2[0])) + SMALL
    @f2[1] += (@highFrequency * (@f2[0] - @f2[1]))
    @f2[2] += (@highFrequency * (@f2[1] - @f2[2]))
    @f2[3] += (@highFrequency * (@f2[2] - @f2[3]))

    h = @sdm[2] - @f2[3]

    m = @sdm[2] - (h + l)

    l *= @lowGain
    m *= @midGain
    h *= @highGain

    @sdm[2] = @sdm[1]
    @sdm[1] = @sdm[0]
    @sdm[0] = input

    Helper.clip l + m + h
