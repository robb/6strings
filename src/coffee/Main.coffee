$ ->
  synth = new Synthesizer

  #Standart tuning
  Tuning = [36, 31, 27, 22, 17, 12]

  Chords = [
    ['G' , 1, 0, 0, 0, 2, 3],
    ['Em', 0, 0, 0, 2, 2, 0],
    ['C' , 0, 1, 0, 2, 3, 0],
    ['Am', 0, 1, 2, 2, 0, 0],
    ['D' , 2, 3, 2, 0, 0, 0],
    ['G2' , 2, 2, 3, 4, 4, 2]
  ]

  $('.neck .string').each (i, string) ->
    for j in [0..6]
      do (i, j) ->
        fret = $('<div class="fret"></div>')
        fret.mouseenter ->
          string = synth.strings[i]
          chord  = Chords[j]

          [chordName, notes...] = chord

          string.setPitch notes[i] + Tuning[i]
          string.pluck = string.L / 3

        $(string).append fret

