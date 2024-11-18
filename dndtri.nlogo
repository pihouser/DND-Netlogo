;; Perry Houser
;; DND horde maze sim

;; Simulate a horde for a D&D campaign where the players get to create a maze
;; that is magically created within a tower keep, the horde count is based on a 100 percentile die.
;; The maze is created from a jpg (1666x1565 pixels) in a file called bound3.jpg.
;; Within photoshop using a 60 px black brush to create walls, players are warned that walls must be
;; straight and with no rounded corners, also spacing between walls and paths must be 60 px or the width
;; of the brush/walls. Players are asked to place themselves on the map, by clicking on the map, the pixel
;; will turn Orange. Once a horde member touches the orange pixel will turn black, and sim will stop.

;; RED pixels represent danger/death to horde members.

;; NOTE: the ticks option on the interface page should be set from Continuous to "on tick"
;;



breed[monsters mapper]

turtles-own [
  goal
  speed
  stuck?
  sx
  sy
  sxa
  sya
  ]

patches-own [
  popularity
  ]

globals [
  feature
  count-tick
  ]

;; Create the start-up button
to setup
  clear-all ;; clear the main screen for a fresh start
  set feature(list)
  ;;set monster_count 60
  import-pcolors "bound.jpg" ;; this is the image of users boundaries and hazards

  setup-patches ;; run the function that will setup the ground level
  setup-traps ;; add the geologic features (faults/depo contacts/folds)
  setup-monsters ;; run the function that will setup the field monsters (people/turtles)
  reset-ticks  ;; reset the clock to zero *netlogo 6 has this line at the end of the setup
end

to go
  check-feature-placement
  ask turtles [move-turtles]
  decay-popularity
  tick
end

to show-gyph
    clear-all ;; clear the main screen for a fresh start
    import-pcolors "bound3.jpg" ;; this is the image of users boundaries and hazards
end

;; preset the ground features
to setup-patches
    ask patches [set popularity 1]
end

;; setup the monsters, aka the field-monsters, turtles
to setup-monsters
    create-turtles monster_count ;; create turtles using the number from the tcount slider
    ask turtles [setxy 12 -10] ;; place users at the starting site of the map
    ask turtles [set shape "person"] ;; change the arrows to a person shape
    set-default-shape monsters "person"
end


;; function to move the turtles around
to move-turtles
     ;;walk-towards-goal
     set sx (round xcor)
     set sy (round ycor)
     set stuck? false
     decay-popularity ;; reduce the path options

    if [ pcolor ] of patch-here = 25 [ stop ]

    if pcolor = black [back 1];; if the pcolor is black then it is a boundary line

    if  pcolor >= 0 and pcolor < 9.9 [back 1];; if the pcolor is black then it is a boundary line

    if ([pcolor] of patch-here = red) [
      set pcolor white
      die
     ]

    if ([ pcolor ] of patch-here >= 11 and [ pcolor ] of patch-here <= 14.9) [
      set pcolor white
      die
    ]

    set sxa (round xcor)
    set sya (round ycor)
    check-stuck
    break-wall
end

to check-stuck
  ifelse (sx = sxa and sy = sya) [
    set stuck? true
    break-wall  ;; if stuck on wall, break thru the wall
  ]
  [ set stuck? false]
end


to break-wall
  if (stuck? = true) [
    set pcolor white
    set stuck? false
    move-turtles
  ]
end


to check-feature-placement
  if mouse-down?
  [ask patch (round mouse-xcor) (round mouse-ycor) [
    ifelse pcolor = 25
    [ unbecome-feature ]
    [ become-feature ]
  ]]
end

to unbecome-feature
  set pcolor white
  set popularity 1
  set feature (remove self feature)
end

to become-feature
  set pcolor 25
  set feature (fput self feature)
end

to decay-popularity
  ask patches with [pcolor != red] [
    if popularity > 1 and not any? turtles-here [ set popularity popularity * (100 - popularity-decay-rate) / 100 ]
    ifelse pcolor = black
    [ if popularity < 1 [ set popularity 1 ] ]
    [ if popularity < 1 [
        set popularity 1
        set pcolor black
        ] ]
  ]
end

to become-more-popular
  set popularity popularity + popularity-per-step
  if popularity > minimum-route-popularity [ set pcolor gray ]
end


to-report route-on-the-way-to [l current-distance]
  let routes-on-the-way-to-goal (patches in-radius person-vision-dist with [
      pcolor = 25 and distance l < current-distance - 1
    ])
  report min-one-of routes-on-the-way-to-goal [distance self]
end

to setup-traps
    ;; set the data on the map
    ask patch 0 0 [set pcolor red]
end
