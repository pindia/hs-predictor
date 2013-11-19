LOG_SET = 1
LOG_INSERT = 2

class GameState
  constructor: (myUnits, enemyUnits) ->
    this.units = enemyUnits
    this.myIndex = enemyUnits.length # Index of first player unit
    for u in myUnits
      this.units.push u
    this.log = []

  damage: (i, amt) ->
    prev = this.units[i]
    this.units[i] -= amt
    if this.units[i] <= 0
      this.log.push([LOG_INSERT, i, prev])
      this.units.splice(i, 1)
      if i < this.myIndex
        this.myIndex -= 1
    else
      this.log.push([LOG_SET, i, prev ])

  getEnemyLength: ->
    return this.myIndex

  getAllLength: ->
    return this.units.length

  undo: ->
    [op, i, val] = this.log.pop()
    if op == LOG_SET
      this.units[i] = val
    else
      this.units.splice(i, 0, val)
      if i <= this.myIndex
        this.myIndex += 1

search = (myUnits, enemyUnits, enemyDamage) ->
  state = new GameState(myUnits, enemyUnits)
  explore = (state, enemyDamageLeft) ->
    if enemyDamageLeft == 0
      console.log state.units
      return
    for i in [0...state.getEnemyLength()]
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
