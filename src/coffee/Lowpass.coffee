class Lowpass extends Filter
  constructor: (gain = 0.995) ->
    @gain     = gain / 2
    @previous = 0

  apply: (input) ->
    output    = @gain * (input + @previous)
    @previous = input

    output
