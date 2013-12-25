module = angular.module( "hs", [] );

class Unit
  constructor: (hp) ->
    this.hp = hp
  modHp: (amt) ->
    this.hp = Math.min(99, Math.max(0, parseInt(this.hp) + amt))

`module.filter('numberFixedLen', function () {
    return function (n, len) {
        var num = parseInt(n, 10);
        len = parseInt(len, 10);
        if (isNaN(num) || isNaN(len)) {
            return n;
        }
        num = ''+num;
        while (num.length < len) {
            num = ' '+num;
        }
        return num;
    };
});`

module.directive 'box', ->
  restrict: 'E'
  scope:
    value: '=value'
  template: '''
    <div class="unit">
        <div class="unit-box">
          <input type="text" ng-model="value">
          <div ng-click="modValue(1)" class="up-arrow"><span class="icon">&#9650;</span></div>
          <div ng-click="modValue(-1)" class="down-arrow"><span class="icon">&#9660;</span></div>
        </div>
    </div>
  '''
  controller: ($scope) ->
    $scope.modValue = (amt) ->
      $scope.value = Math.min(99, Math.max(0, parseInt($scope.value) + amt))

module.directive 'unit', ->
  restrict: 'E'
  scope:
    unit: '=unit'
  template: '''
    <div class="unit" ng-class="{disabled: unit.hp==0}" data-hp="{{unit.hp}}">
        <div class="unit-box">
          <input type="text" ng-model="unit.hp">
          <div ng-click="unit.modHp(1)" class="up-arrow"><span class="icon">&#9650;</span></div>
          <div ng-click="unit.modHp(-1)" class="down-arrow"><span class="icon">&#9660;</span></div>
        </div>
        <div class="results-box">
          <table ng-show="unit.hp > 0">
              <tr ng-repeat="(dmg, prob) in unit.results" ng-class="{lethal: dmg == unit.hp}">
                  <td>{{dmg}}</td>
                  <td title="{{prob}}">{{prob*100|numberFixedLen:3}}%</td>
              </tr>
          </table>
        </div>
    </div>
  '''

module.factory 'unitsService', ->
  units = {
    my: [new Unit(30), new Unit(0), new Unit(0), new Unit(0), new Unit(0), new Unit(0), new Unit(0), new Unit(0)],
    enemy: [new Unit(30), new Unit(2), new Unit(0), new Unit(0), new Unit(0), new Unit(0), new Unit(0), new Unit(0)]}
  return units


serializeScope = ($scope, myUnits, enemyUnits) ->
  return $scope.enemyDamage + ',' + $scope.allDamage + ';' + (unit.hp for unit in myUnits).join(',') + ';' + (unit.hp for unit in enemyUnits).join(',')

unserializeScope = ($scope, unitsService) ->
  bits = window.location.hash.slice(1).split(';')
  [$scope.enemyDamage, $scope.allDamage] = bits[0].split(',')
  unitsService.my = (new Unit(parseInt(hp)) for hp in bits[1].split(','))
  unitsService.enemy = (new Unit(parseInt(hp)) for hp in bits[2].split(','))
  console.log unitsService.my


window.MainController = ($scope, unitsService) ->
  $scope.enemyDamage = 3
  $scope.allDamage = 0
  $scope.trials = 0
  $scope.$watch 'enemyDamage', -> $scope.$emit('unitsChanged')
  $scope.$watch 'allDamage', -> $scope.$emit('unitsChanged')
  if window.location.hash
    unserializeScope($scope, unitsService)
  $scope.$on 'unitsChanged', ->
    window.location.hash = serializeScope($scope, unitsService.my, unitsService.enemy)
    myUnits = (unit.hp for unit in unitsService.my)
    enemyUnits = (unit.hp for unit in unitsService.enemy)
    for arr in [myUnits, enemyUnits]
      firstZero = arr.length
      for i in [arr.length-1..1]
        if arr[i] == 0
          firstZero = i
        else
          break
      arr.splice(firstZero, arr.length - firstZero)
    myIndex = enemyUnits.length

    damageAmounts = []
    damageTypes = []
    for i in [0...$scope.allDamage]
      damageAmounts.push 1
      damageTypes.push true
    for i in [0...$scope.enemyDamage]
      damageAmounts.push 1
      damageTypes.push false

    console.log damageTypes


    console.log myUnits

    if damageAmounts.length * (myUnits.length + enemyUnits.length) > 50
      trials = 1000
      results = simulate(myUnits, enemyUnits, damageAmounts, damageTypes, trials)
      $scope.trials = trials
    else
      results = calculate(myUnits, enemyUnits, damageAmounts, damageTypes)
      $scope.trials = 0

    for res, i in results.data.slice(0, myIndex)
      unitsService.enemy[i].results = res
    for res, i in results.data.slice(myIndex)
      unitsService.my[i].results = res

window.Side = ($scope, unitsService) ->
  $scope.init = (which) ->
    $scope.units = unitsService[which]
  $scope.$watch('units', ->
    $scope.$emit('unitsChanged')
  , true)

#window.Results = ($scope, resultsService) ->
#  $scope.init = (which) ->
#    $scope.results = resultsService[which]
#    $scope.$on 'newResults', ->
#      $scope.results = resultsService[which]


#
#
#window.Unit = ($scope) ->
#  $scope.hp = 0
#  $scope.$watch 'hp', ->
#    $scope.hp = Math.min(99, Math.max(0, $scope.hp))
#  $scope.modHp = (amt) ->
#    $scope.hp += amt
#    #$scope.hp = Math.max(0, $scope.hp + amt)