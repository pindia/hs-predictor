(function() {
  var GameState, ProbabilityAggregator, d, i;

  GameState = (function() {

    function GameState(myUnits, enemyUnits) {
      var u, _i, _len;
      this.units = enemyUnits;
      this.myIndex = enemyUnits.length;
      for (_i = 0, _len = myUnits.length; _i < _len; _i++) {
        u = myUnits[_i];
        this.units.push(u);
      }
      this.logIndex = [];
      this.logValues = [];
    }

    GameState.prototype.each = function(includeFriendly, callback) {
      var i, len, n;
      len = includeFriendly ? this.units.length : this.myIndex;
      n = 0;
      for (i = 0; i < len; i++) {
        if (this.units[i] > 0) {
            n += 1;
        }
      }
      for (i = 0; i < len; i++) {
        if (this.units[i] > 0) {
          callback(i, n);
        }
      }
    };

    GameState.prototype.damage = function(i, amt) {
      var prev;
      prev = this.units[i];
      this.units[i] -= amt;
      this.logIndex.push(i);
      this.logValues.push(prev);
    };

    GameState.prototype.undo = function() {
     this.units[this.logIndex.pop()] = this.logValues.pop();
    };

    return GameState;

  })();

  ProbabilityAggregator = (function() {

    function ProbabilityAggregator(units) {
      var i, _ref;
      this.units = [];
      this.data = [];
      for (i = 0, _ref = units.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        this.units.push(units[i]);
        this.data.push({});
      }
    }

    ProbabilityAggregator.prototype.addResult = function(i, damage, prob) {
      var d;
      d = this.data[i];
      if (!(damage in d)) d[damage] = 0;
      d[damage] += prob;
    };

    ProbabilityAggregator.prototype.addResults = function(results, prob) {
      var i, _ref;
      for (i = 0, _ref = results.length; i < _ref; i++) {
        this.addResult(i, this.units[i] - results[i], prob);
      }
    };

    return ProbabilityAggregator;

  })();

  window.search = function(myUnits, enemyUnits, damageAmounts, damageTypes) {
    var agg, damageLength, explore, state;
    state = new GameState(myUnits, enemyUnits);
    agg = new ProbabilityAggregator(state.units);
    damageLength = damageAmounts.length;
    explore = function(damageIndex, probability) {
      if (damageIndex < damageLength) {
        state.each(damageTypes[damageIndex], function(i, n) {
          state.damage(i, damageAmounts[damageIndex]);
          explore(damageIndex + 1, probability / n);
          state.undo();
        });
      } else {
        agg.addResults(state.units, probability);
      }
    };
    explore(0, 1);
    return agg;
  };

  d = new Date();

  for (i = 1; i <= 500; i++) {
    search([30, 2], [30, 2, 2, 2, 2], [1, 1, 1, 1, 1, 1, 1], [false, false, false, false, false, false, false, false]);
  }

  console.log(new Date() - d);

}).call(this);
