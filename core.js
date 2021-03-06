// Generated by CoffeeScript 1.10.0
(function() {
  var GameState, ProbabilityAggregator;

  GameState = (function() {
    function GameState(myUnits, enemyUnits) {
      var k, len1, u;
      this.units = enemyUnits;
      this.myIndex = enemyUnits.length;
      for (k = 0, len1 = myUnits.length; k < len1; k++) {
        u = myUnits[k];
        this.units.push(u);
      }
      this.logIndex = [];
      this.logValues = [];
    }

    GameState.prototype.each = function(includeFriendly, callback) {
      var i, k, len, m, n, ref, ref1;
      len = includeFriendly ? this.units.length : this.myIndex;
      n = 0;
      for (i = k = 0, ref = len; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        if (this.units[i] > 0) {
          n += 1;
        }
      }
      for (i = m = 0, ref1 = len; 0 <= ref1 ? m < ref1 : m > ref1; i = 0 <= ref1 ? ++m : --m) {
        if (this.units[i] > 0) {
          callback(i, n);
        }
      }
      return void 0;
    };

    GameState.prototype.random = function(includeFriendly, callback) {
      var i, k, len, m, n, ref, ref1, targetIndex;
      len = includeFriendly ? this.units.length : this.myIndex;
      n = 0;
      for (i = k = 0, ref = len; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        if (this.units[i] > 0) {
          n += 1;
        }
      }
      targetIndex = parseInt(n * Math.random());
      for (i = m = 0, ref1 = len; 0 <= ref1 ? m < ref1 : m > ref1; i = 0 <= ref1 ? ++m : --m) {
        if (this.units[i] > 0) {
          if (targetIndex === 0) {
            callback(i);
            return;
          }
          targetIndex -= 1;
        }
      }
      return void 0;
    };

    GameState.prototype.damage = function(i, amt) {
      var prev;
      prev = this.units[i];
      this.units[i] -= amt;
      this.logIndex.push(i);
      return this.logValues.push(prev);
    };

    GameState.prototype.undo = function() {
      return this.units[this.logIndex.pop()] = this.logValues.pop();
    };

    return GameState;

  })();

  ProbabilityAggregator = (function() {
    function ProbabilityAggregator(units) {
      var i, k, ref;
      this.units = [];
      this.data = [];
      for (i = k = 0, ref = units.length; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        this.units.push(units[i]);
        this.data.push({});
      }
    }

    ProbabilityAggregator.prototype.addResult = function(i, damage, prob) {
      var d;
      d = this.data[i];
      if (!(damage in d)) {
        d[damage] = 0;
      }
      return d[damage] += prob;
    };

    ProbabilityAggregator.prototype.addResults = function(results, prob) {
      var i, k, ref;
      for (i = k = 0, ref = results.length; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        this.addResult(i, this.units[i] - results[i], prob);
      }
      return void 0;
    };

    return ProbabilityAggregator;

  })();

  window.calculate = function(myUnits, enemyUnits, damageAmounts, damageTypes) {
    var agg, damageLength, explore, state;
    state = new GameState(myUnits, enemyUnits);
    agg = new ProbabilityAggregator(state.units);
    damageLength = damageAmounts.length;
    explore = function(damageIndex, probability) {
      if (damageIndex < damageLength) {
        return state.each(damageTypes[damageIndex], function(i, n) {
          state.damage(i, damageAmounts[damageIndex]);
          explore(damageIndex + 1, probability / n);
          return state.undo();
        });
      } else {
        return agg.addResults(state.units, probability);
      }
    };
    explore(0, 1);
    return agg;
  };

  window.simulate = function(myUnits, enemyUnits, damageAmounts, damageTypes, trials) {
    var agg, damageIndex, i, j, k, l, m, o, ref, ref1, ref2, state;
    state = new GameState(myUnits, enemyUnits);
    agg = new ProbabilityAggregator(state.units);
    for (i = k = 0, ref = trials; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
      for (damageIndex = m = 0, ref1 = damageAmounts.length; 0 <= ref1 ? m < ref1 : m > ref1; damageIndex = 0 <= ref1 ? ++m : --m) {
        l = [];
        state.random(damageTypes[damageIndex], function(i) {
          return state.damage(i, damageAmounts[damageIndex]);
        });
      }
      agg.addResults(state.units, 1 / trials);
      for (j = o = 0, ref2 = damageAmounts.length; 0 <= ref2 ? o < ref2 : o > ref2; j = 0 <= ref2 ? ++o : --o) {
        state.undo();
      }
    }
    return agg;
  };

}).call(this);
