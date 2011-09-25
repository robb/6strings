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
    @renderer    = new Renderer @, =>
      @renderer.draw()

      $('body').bind 'mousedown', @mousedown
      $('body').bind 'mousemove', @mousemove
      $('body').bind 'mouseup',   @mouseup

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
    x = event.pageX - $('#main-canvas').offset().left
    y = event.pageY - $('#main-canvas').offset().top

    unless 0 <= y <= @renderer.canvas.height
      return [null, null]

    fret   = Math.floor(x / @renderer.fretWidth)
    string = Math.ceil((y - 30) / 32)

    [fret, string]

  # Event handlers
  mousedown: (event) =>
    @pick event if @mode is 'notes'

  mousemove: (event) =>
    @strum event if @mode is 'chords'
    @bend  event if @mode is 'notes'

  mouseup: (event) =>
    @release event if @mode is 'notes'

  # Actions
  reset: ->
    [@currentFret, @currentString] = [null, null]
    @bendingString = null

  strum: (event) ->
    [fret, string] = @getfretAndString event
    
    console.log fret, string

    return unless fret? and string?

    synthesizerString = @synthesizer.strings[string]

    if fret isnt @currentFret or string isnt @currentString
      [@currentFret, @currentString] = [fret, string]

      [name, notes...] = @chords[fret]
      pitch = notes[string] + @tuning[string]

      synthesizerString.setPitch pitch
      synthesizerString.pluck = synthesizerString.L / 3

      @renderer.oscillation[string] = 2 + string*string / 6

  pick: (event) ->
    [fret, string] = @getfretAndString event

    return unless fret? and string?

    [@currentFret, @currentString] = [fret, string]
    synthesizerString = @synthesizer.strings[string]

    pitch = fret + @tuning[string]

    synthesizerString.setPitch pitch
    synthesizerString.pluck = synthesizerString.L / 2

    @renderer.oscillation[string] = 3 + string*string / 6

  bend: (event) ->
    x = event.pageX - $('#main-canvas').offset().left
    y = event.pageY - $('#main-canvas').offset().top

    @bendingString = @currentString
    stringPosition = 20.5 + @currentString * (@renderer.canvas.height - 40) / 5

    y = stringPosition - 29 if y < stringPosition - 29
    y = stringPosition + 29 if y > stringPosition + 29
    y = 2 if y < 2
    y = @renderer.canvas.height - 2 if y > @renderer.canvas.height - 2

    @bendingCoordinates = [x, y]

  release: (event) ->
    @reset()
