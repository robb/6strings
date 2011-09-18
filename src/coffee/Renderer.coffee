class Renderer
  constructor: (@synthesizer, onload) ->
    @fretWidth = 120

    @canvas  = document.getElementById 'main-canvas'
    @canvas.width  = $(window).width()
    @canvas.height = 200
    @context = @canvas.getContext '2d'

    @createDrawingContexts()

    @oscillation = new Array 6

    # Load fret graphic
    @fret = new Image
    @fret.onload = =>

      lastResized = 0
      $(window).bind 'resize', =>
          @resizeCanvas()

      onload?()

    @fret.src = '../img/fret.png'

  createDrawingContexts: ->
    createCanvasAndContext = (width, height) =>
      canvas = document.createElement 'canvas'
      canvas.width  = width  or @canvas.width
      canvas.height = height or @canvas.height
      context = canvas.getContext '2d'

      [canvas, context]

    # Create a layer for the frets and one for the strings
    [@fretsLayer,   @fretsLayerContext]   = createCanvasAndContext()
    [@stringsLayer, @stringsLayerContext] = createCanvasAndContext()

    # Prepare textures for the light (topmost two)
    # and heavy (remaining) strings.
    [@lightTexture, lightTextureContext] = createCanvasAndContext()

    # TODO: consider adding some texture here, too
    lightTextureContext.fillStyle = 'DDDDDD'
    lightTextureContext.fillRect 0, 0, @lightTexture.width, @lightTexture.height

    # Create a pattern for the heavy strings, consisting of vertical
    # stripes that looks like the wound wire of the string
    [heavyTexturePattern, heavyTexturePatternContext] = createCanvasAndContext 2, 1

    heavyTexturePatternContext.fillStyle = 'ECECEC'
    heavyTexturePatternContext.fillRect 0, 0, 1, 1
    heavyTexturePatternContext.fillStyle = 'CBCBCB'
    heavyTexturePatternContext.fillRect 1, 0, 1, 1

    pattern = heavyTexturePatternContext.createPattern heavyTexturePattern, 'repeat'

    # Create heavy texture with that pattern
    [@heavyTexture, heavyTextureContext] = createCanvasAndContext()

    heavyTextureContext.fillStyle = pattern
    heavyTextureContext.fillRect 0, 0, @heavyTexture.width, @heavyTexture.height

    # Prepare sub-layers for the light and heavy strings
    [@lightLayer, @lightLayerContext] = createCanvasAndContext()
    [@heavyLayer, @heavyLayerContext] = createCanvasAndContext()

  resizeCanvas: ->
    @canvas.width = $(window).width()
    @createDrawingContexts()
    @draw()

  draw: ->
    @drawFrets()
    @drawStrings()

    @context.clearRect 0, 0, @canvas.width, @canvas.height
    @context.drawImage @fretsLayer,   0, 0, @canvas.width, @canvas.height
    @context.drawImage @stringsLayer, 0, 0, @canvas.width, @canvas.height

  drawFrets: ->
    @fretsLayerContext.clearRect 0, 0, @fretsLayer.width, @fretsLayer.height

    # TODO: Consider uneven i.e. realistic spacing between frets
    x = @fretWidth
    while x < @fretsLayer.width
      @fretsLayerContext.drawImage @fret, x, 0, @fret.width, @fretsLayer.height
      x += @fretWidth

  drawStrings: ->
    # Clear all layers we'll need
    @stringsLayerContext.clearRect 0, 0, @stringsLayer.width, @stringsLayer.height
    @lightLayerContext.clearRect 0, 0, @lightLayer.width, @lightLayer.height
    @heavyLayerContext.clearRect 0, 0, @heavyLayer.width, @heavyLayer.height

    @lightLayerContext.globalCompositeOperation = 'source-over'
    @heavyLayerContext.globalCompositeOperation = 'source-over'

    # Draw strings
    for string in [0..6]
      y = 20.5 + string * (@canvas.height - 40) / 5

      context = if string < 2 then @lightLayerContext else @heavyLayerContext

      stringWidth = 2 + string * 0.4 + @oscillation[string]

      context.strokeStyle = 'black'
      context.lineWidth = stringWidth
      context.beginPath()
      context.moveTo 0, y
      context.lineTo @lightLayer.width, y
      context.closePath()
      context.stroke()

    @lightLayerContext.globalCompositeOperation = 'source-in'
    @heavyLayerContext.globalCompositeOperation = 'source-in'

    @lightLayerContext.drawImage @lightTexture, 0, 0, @lightLayer.width, @lightLayer.height
    @heavyLayerContext.drawImage @heavyTexture, 0, 0, @heavyLayer.width, @heavyLayer.height

    @lightLayerContext.globalCompositeOperation = 'darker'
    @heavyLayerContext.globalCompositeOperation = 'darker'

    # draw shading on strings
    for string in [0..6]
      break if @oscillation[string] > 0

      y = 20.5 + string * (@canvas.height - 40) / 5

      context = if string < 2 then @lightLayerContext else @heavyLayerContext

      stringWidth = 2 + string * 0.4

      gradient = context.createLinearGradient 0, y - stringWidth / 2,
                                              0, y + stringWidth / 2
      gradient.addColorStop 0.0, 'AAAAAA'
      gradient.addColorStop 0.5, 'FFFFFF'
      gradient.addColorStop 1.0, 'AAAAAA'

      context.strokeStyle = gradient
      context.lineWidth = stringWidth
      context.beginPath()
      context.moveTo 0, y
      context.lineTo @lightLayer.width, y
      context.closePath()
      context.stroke()

    @stringsLayerContext.globalCompositeOperation = 'source-over'
    @stringsLayerContext.drawImage @lightLayer, 0, 0, @stringsLayer.width, @stringsLayer.height
    @stringsLayerContext.drawImage @heavyLayer, 0, 0, @stringsLayer.width, @stringsLayer.height

    @lightLayerContext.globalCompositeOperation = 'darken'
    @heavyLayerContext.globalCompositeOperation = 'darken'

    # draw shadow
    for string in [0..6]
      y = 20.5 + string * (@canvas.height - 40) / 5

      stringWidth = 2 + string * 0.4

      @stringsLayerContext.shadowColor = '000000'
      @stringsLayerContext.shadowBlur  = 7
      @stringsLayerContext.shadowOffsetY = 7
      @stringsLayerContext.strokeStyle = 'transparent'
      @stringsLayerContext.lineWidth = stringWidth
      @stringsLayerContext.beginPath()
      @stringsLayerContext.moveTo 0, y
      @stringsLayerContext.lineTo @lightLayer.width, y
      @stringsLayerContext.closePath()
      @stringsLayerContext.stroke()

    for string in [0..6]
      @oscillation[string] -= @oscillation[string] / 60
      @oscillation[string] = 0 if @oscillation[string] < 0.025
