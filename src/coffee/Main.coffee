$ ->
  window.synth = new Synthesizer

  #Standart tuning
  Tuning = [36, 31, 27, 22, 17, 12]

  Chords = [
    ['G' , 3, 0, 0, 0, 2, 3],
    ['Em', 0, 0, 0, 2, 2, 0],
    ['C' , 0, 1, 0, 2, 3, 0],
    ['Am', 0, 1, 2, 2, 0, 0],
    ['D' , 2, 3, 2, 0, 0, 0],
    ['G2' , 2, 2, 3, 4, 4, 2]
  ]

  $('.neck .fret').each (i, fret) ->
    for j in [0...6]
      do (i, j) ->
        string = $('<div class="string"></div>')
        string.mouseenter ->
          synthString = synth.strings[j]
          chord  = Chords[i]

          [chordName, notes...] = chord

          synthString.setPitch notes[j] + Tuning[j]
          synthString.pluck = synthString.L / 3

        $(fret).append string

