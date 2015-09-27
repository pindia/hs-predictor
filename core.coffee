class GameState
  constructor: (myUnits, enemyUnits) ->
    this.units = enemyUnits
    this.myIndex = enemyUnits.length # Index of first player unit
    for u in myUnits
      this.units.push u
    this.logIndex = [] # Logs of what damage has done, for fast undo when exploring other possibilities
    this.logValues = []

  # Calls a callback for each living unit in the game. For exhaustive search of possibility space
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


  # Calls a callback for a random living unit in the game. For simulation of possibilities
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
    this.units = [] # Initial health of all units in the game
    this.data = [] # List containing a map of damage values to probability for each unit
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

# Main calculation/simulations functions. Take list of my unit HP, list of enemy unit HP,
# list of independently applied damage amounts (e.g. arcane missiles is [1, 1, 1]),
# list of whether each damage packet has friendly fire (e.g. missiles = [false, false, false],
# bomber = [true, true, true])

window.calculate = (myUnits, enemyUnits, damageAmounts, damageTypes) ->
  state = new GameState(myUnits, enemyUnits)
  agg = new ProbabilityAggregator(state.units)
  damageLength = damageAmounts.length
  explore = (damageIndex, probability) ->
    if damageIndex < damageLength
      state.each damageTypes[damageIndex], (i, n) ->
        state.damage(i, damageAmounts[damageIndex])
        explore(damageIndex + 1, probability/n) # divide probability by n because the tree has n equal probability branches
        state.undo() # undo after this path is explored. much faster than copying
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