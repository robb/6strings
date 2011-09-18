class Renderer
  constructor: (synthesizer, onload) ->
    @canvas  = document.getElementById 'main-canvas'
    @canvas.width  = $(window).width()
    @canvas.height = 200
    @context = @canvas.getContext '2d'

    @initialize()

    $(window).bind 'resize', =>
      @resizeCanvas()

  initialize: ->
    # Prepare textures for the light (topmost two)
    # and heavy (remaining) strings.
    @lightTexture = document.createElement 'canvas'
    @lightTexture.width  = @canvas.width
    @lightTexture.height = @canvas.height
    lightTextureContext  = @lightTexture.getContext '2d'

    # TODO: consider adding some texture here, too
    lightTextureContext.fillStyle = 'DDDDDD'
    lightTextureContext.fillRect 0, 0, @lightTexture.width, @lightTexture.height

    # Create a pattern for the heavy strings, consisting of vertical
    # stripes that looks like the wound wire of the string
    heavyTexturePattern = document.createElement 'canvas'
    heavyTexturePattern.width  = 2
    heavyTexturePattern.height = 1
    heavyTexturePatternContext = heavyTexturePattern.getContext '2d'

    heavyTexturePatternContext.fillStyle = 'ECECEC'
    heavyTexturePatternContext.fillRect 0, 0, 1, 1
    heavyTexturePatternContext.fillStyle = 'CBCBCB'
    heavyTexturePatternContext.fillRect 1, 0, 1, 1

    pattern = heavyTexturePatternContext.createPattern heavyTexturePattern, 'repeat'

    @heavyTexture = document.createElement 'canvas'
    @heavyTexture.width  = @canvas.width
    @heavyTexture.height = @canvas.height
    heavyTextureContext  = @heavyTexture.getContext '2d'

    heavyTextureContext.fillStyle = pattern
    heavyTextureContext.fillRect 0, 0, @heavyTexture.width, @heavyTexture.height

    # Prepare layers for the light and heavy strings
    @lightLayer = document.createElement 'canvas'
    @lightLayer.width  = @canvas.width
    @lightLayer.height = @canvas.height
    @lightLayerContext = @lightLayer.getContext '2d'

    @heavyLayer = document.createElement 'canvas'
    @heavyLayer.width  = @canvas.width
    @heavyLayer.height = @canvas.height
    @heavyLayerContext = @heavyLayer.getContext '2d'

  resizeCanvas: ->
    @canvas.width = $(window).width()
    @initialize()
    @draw()

  clear: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height
    @lightLayerContext.clearRect 0, 0, @lightLayer.width, @lightLayer.height
    @heavyLayerContext.clearRect 0, 0, @heavyLayer.width, @heavyLayer.height

  draw: ->
    console.time "draw" if DEBUG
    @clear()

    @lightLayerContext.globalCompositeOperation = 'source-over'
    @heavyLayerContext.globalCompositeOperation = 'source-over'

    for string in [0..6]
      y = 20 + string * (@canvas.height - 40) / 5

      context = if string < 2 then @lightLayerContext else @heavyLayerContext

      stringWidth = 2 + string * 0.4

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

    for string in [0..6]
      y = 20 + string * (@canvas.height - 40) / 5

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

    @context.globalCompositeOperation = 'source-over'
    @context.drawImage @lightLayer, 0, 0, @canvas.width, @canvas.height
    @context.drawImage @heavyLayer, 0, 0, @canvas.width, @canvas.height

    console.timeEnd "draw" if DEBUG
