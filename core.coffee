class GameState
  constructor: (myUnits, enemyUnits) ->
    this.units = enemyUnits
    this.myIndex = enemyUnits.length # Index of first player unit
    for u in myUnits
      this.units.push u
    this.logIndex = [] # Logs of what damage has done, for fast undo when exploring other possibilities
    this.logValues = []

  each: (includeFriendly, callback) ->
    len = if includeFriendly then this.units.length else this.myIndex
    n = 0
    for i in [0...len] # Calculate number of eligible units
      if this.units[i] > 0
        n += 1
    for i in [0...len] # Call callback for each eligible unit
      if this.units[i] > 0
        callback(i, n)
    return undefined # Stop CoffeeScript from being dumb and building a results array

  random: (includeFriendly, callback) ->
    len = if includeFriendly then this.units.length else this.myIndex
    n = 0
    for i in [0...len] # Calculate number of eligible units
      if this.units[i] > 0
        n += 1
    targetIndex = parseInt(n*Math.random())
    for i in [0...len]
      if this.units[i] > 0
        if targetIndex == 0
          callback(i)
          return
        targetIndex -= 1
    return undefined # Stop CoffeeScript from being dumb and building a results array


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
    return undefined # Stop CoffeeScript from being dumb and building a results array

window.calculate = (myUnits, enemyUnits, damageAmounts, damageTypes) ->
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

window.simulate = (myUnits, enemyUnits, damageAmounts, damageTypes, trials) ->
  state = new GameState(myUnits, enemyUnits)
  agg = new ProbabilityAggregator(state.units)
  for i in [0...trials]
    for damageIndex in [0...damageAmounts.length]
      l = []
      state.random damageTypes[damageIndex], (i) ->
        state.damage(i, damageAmounts[damageIndex])
    agg.addResults(state.units, 1/trials)
    for j in [0...damageAmounts.length]
      state.undo()
  return agg