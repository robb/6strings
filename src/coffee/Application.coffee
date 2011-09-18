class Application
  constructor: ->
    @mode = 'chords'

    @tuning = [36, 31, 27, 22, 17, 12]
    @chords = [
      ['G' , 3, 0, 0, 0, 2, 3],
      ['Em', 0, 0, 0, 2, 2, 0],
      ['C' , 0, 1, 0, 2, 3, 0],
      ['Am', 0, 1, 2, 2, 0, 0],
      ['D' , 2, 3, 2, 0, 0, 0],
      ['G2' , 2, 2, 3, 4, 4, 2]
    ]

    @synthesizer = new Synthesizer
    @renderer    = new Renderer @synthesizer, =>
      @renderer.draw()

      # Set up strumming
      currentFret   = -1
      currentString = -1
      $(@renderer.canvas).bind 'mousemove', (event) =>
        fret   = Math.floor(event.offsetX / @renderer.fretWidth)
        string = Math.ceil((event.offsetY - 20) / 32)

        if fret isnt currentFret or string isnt currentString
          currentFret   = fret
          currentString = string

          synthesizerString = @synthesizer.strings[string]

          if @mode is 'chords'
            [name, notes...] = @chords[fret]

            pitch = notes[string] + @tuning[string]
          else
            pitch = fret + @tuning[string]

          if pitch
            synthesizerString.setPitch pitch
            synthesizerString.pluck = synthesizerString.L / 3

            @renderer.oscillation[string] = 2 + string*string / 6

      # Set up rendering loop
      drawingLoop = =>
        @renderer.draw()

        setTimeout drawingLoop, 1000 / 25

      drawingLoop()

      # Set up toggle button
      $('#notes').click =>
        return if $('#notes').hasClass 'active'

        $('.switch .label').toggleClass 'active'
        @mode = 'notes'

      $('#chords').click =>
        return if $('#chords').hasClass 'active'

        $('.switch .label').toggleClass 'active'
        @mode = 'chords'
