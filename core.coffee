class GameState
  constructor: (myUnits, enemyUnits) ->
    this.units = enemyUnits
    this.myIndex = enemyUnits.length # Index of first player unit
    for u in myUnits
      this.units.push u
    this.log = []

  _each: (includeFriendly, callback) ->
    n = (if includeFriendly then this.units.length else this.myIndex)
    e = 0
    for i in [0...n]
      if this.units[i] > 0
        e += 1
    for i in [0...n]
      if this.units[i] > 0
        callback(i, e)

  each: (callback) -> this._each(true, callback)
  eachEnemy: (callback) -> this._each(false, callback)

  damage: (i, amt) ->
    prev = this.units[i]
    this.units[i] -= amt
    this.log.push([i, prev ])

  undo: ->
    [i, val] = this.log.pop()
    this.units[i] = val

class ProbabilityAggregator
  constructor: (units) ->
    this.units = []
    this.data = []
    for i in [0...units.length]
      this.units.push units[i] # Copy list
      this.data.push {}

  addResult: (i, damage, prob) ->
    d = this.data[i]
    if damage not of d
      d[damage] = 0
    d[damage] += prob

  addResults: (results, prob) ->
    for i in [0...results.length]
      this.addResult(i, this.units[i] - results[i], prob)


window.search = (myUnits, enemyUnits, enemyDamage, allDamage) ->
  state = new GameState(myUnits, enemyUnits)
  agg = new ProbabilityAggregator(state.units)
  explore = (state, enemyDamageLeft, allDamageLeft, probability) ->
    if allDamageLeft > 0
      state.each (i, n) ->
        state.damage(i, 1)
        explore(state, enemyDamageLeft, allDamageLeft - 1, probability/n)
        state.undo()
    else if enemyDamageLeft > 0
      state.eachEnemy (i, n) ->
        state.damage(i, 1)
        explore(state, enemyDamageLeft - 1, allDamageLeft, probability/n)
        state.undo()
    else
      agg.addResults(state.units, probability)
  explore(state, enemyDamage, allDamage, 1)
  return agg