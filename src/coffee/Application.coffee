class Application
  constructor: ->
    @synthesizer = new Synthesizer
    @renderer    = new Renderer @synthesizer

    @mode = 'chords'

    @renderer.draw()
