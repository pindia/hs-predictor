class GameState
  constructor: (myUnits, enemyUnits) ->
    this.units = enemyUnits
    this.myIndex = enemyUnits.length # Index of first player unit
    for u in myUnits
      this.units.push u
    this.logIndex = []
    this.logValues = []
    this.numFriendly = 0

  each: (includeFriendly, callback) ->
    len = if includeFriendly then this.units.length else this.myIndex
    n = 0
    for i in [0...len] # Calculate number of eligible units
      if this.units[i] > 0
        n += 1
    for i in [0...len] # Call callback for each eligible unit
      if this.units[i] > 0
        callback(i, n)

  damage: (i, amt) ->
    prev = this.units[i]
    this.units[i] -= amt
    this.logIndex.push(i)
    this.logValues.push(prev)

  undo: ->
    this.units[this.logIndex.pop()] = this.logValues.pop()

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

window.search = (myUnits, enemyUnits, damageAmounts, damageTypes) ->
  state = new GameState(myUnits, enemyUnits)
  agg = new ProbabilityAggregator(state.units)
  damageLength = damageAmounts.length
  explore = (damageIndex, probability) ->
    if damageIndex < damageLength
      state.each damageTypes[damageIndex], (i, n) ->
        state.damage(i, damageAmounts[damageIndex])
        explore(damageIndex + 1, probability/n)
        state.undo()
    else
      agg.addResults(state.units, probability)
  explore(0, 1)
  return agg

d = new Date()
for i in [1..500]
  search([30, 2], [30, 2, 2, 2, 2], [1, 1, 1, 1, 1, 1, 1], [false, false, false, false, false, false, false, false])
console.log new Date() - d