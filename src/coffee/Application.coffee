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

      for event in ['mousedown', 'mousemove', 'mouseup']
        $(@renderer.canvas).bind event, @[event]

      # Set up rendering loop
      drawingLoop = =>
        @renderer.draw()

        setTimeout drawingLoop, 1000 / 25

      drawingLoop()

      # Set up toggle button
      $('#notes').click =>
        return if $('#notes').hasClass 'active'

        $('#notes-or-chords .label').toggleClass 'active'
        @mode = 'notes'
        @reset()

      $('#chords').click =>
        return if $('#chords').hasClass 'active'

        $('#notes-or-chords .label').toggleClass 'active'
        @mode = 'chords'
        @reset()

  getfretAndString: (event) ->
    fret   = Math.floor(event.offsetX / @renderer.fretWidth)
    string = Math.ceil((event.offsetY - 30) / 32)

    [fret, string]

  # Event handlers
  mousedown: (event) =>
    @pick event if @mode is 'notes'

  mousemove: (event) =>
    @strum event if @mode is 'chords'

  mouseup: (event) =>
    @release event if @mode is 'notes'

  # Actions
  reset: ->
    [@currentFret, @currentString] = [null, null]

  strum: (event) ->
    [fret, string]    = @getfretAndString event
    synthesizerString = @synthesizer.strings[string]

    if fret isnt @currentFret or string isnt @currentString
      [@currentFret, @currentString] = [fret, string]

      [name, notes...] = @chords[fret]
      pitch = notes[string] + @tuning[string]

      synthesizerString.setPitch pitch
      synthesizerString.pluck = synthesizerString.L / 3

      @renderer.oscillation[string] = 2 + string*string / 6

  pick: (event) ->
    [@currentFret, @currentString] = [fret, string]

    [fret, string] = @getfretAndString event
    synthesizerString = @synthesizer.strings[string]

    pitch = fret + @tuning[string]

    synthesizerString.setPitch pitch
    synthesizerString.pluck = synthesizerString.L / 2

    @renderer.oscillation[string] = 3 + string*string / 6

  release: (event) ->
    @reset()
