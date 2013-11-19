class GameState
  constructor: (myUnits, enemyUnits) ->
    this.units = enemyUnits
    this.myIndex = enemyUnits.length # Index of first player unit
    for u in myUnits
      this.units.push u
    this.log = []

  _each: (includeFriendly, callback) ->
    for i in [0...(if includeFriendly then this.units.length else this.myIndex)]
      if this.units[i] > 0
        callback(i)

  each: (callback) -> this._each(true, callback)
  eachEnemy: (callback) -> this._each(false, callback)

  damage: (i, amt) ->
    prev = this.units[i]
    this.units[i] -= amt
    this.log.push([i, prev ])

  undo: ->
    [i, val] = this.log.pop()
    this.units[i] = val

search = (myUnits, enemyUnits, enemyDamage) ->
  state = new GameState(myUnits, enemyUnits)
  explore = (state, enemyDamageLeft) ->
    if enemyDamageLeft == 0
      console.log state.units
      return
    state.eachEnemy (i) ->
      state.damage(i, 1)
      explore(state, enemyDamageLeft - 1)
      state.undo()
  explore(state, enemyDamage)


#gs = new GameState([30], [30, 2])
#gs.damage(0, 30)
#gs.undo()
#gs.damage(1, 2)
#gs.undo()
#
#console.log gs.getAllLength()

search([30], [30, 2], 3)
