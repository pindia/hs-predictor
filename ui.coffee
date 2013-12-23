module = angular.module( "hs", [] );

class Unit
  constructor: (hp) ->
    this.hp = hp
  modHp: (amt) ->
    this.hp = Math.min(99, Math.max(0, parseInt(this.hp) + amt))


module.directive 'unit', ->
  restrict: 'E'
  scope:
    unit: '=unit'
  template: '''
    <div class="unit" ng-class="{disabled: unit.hp==0}">
        <div class="unit-box">
          <input type="text" ng-model="unit.hp">
          <div ng-click="unit.modHp(1)" class="up-arrow">&#9650;</div>
          <div ng-click="unit.modHp(-1)" class="down-arrow">&#9660;</div>
        </div>
        <div class="results-box">
          <table ng-show="unit.hp > 0">
              <tr ng-repeat="(dmg, prob) in unit.results" ng-class="{lethal: dmg == unit.hp}">
                  <td>{{dmg}}</td>
                  <td title="{{prob}}">{{prob*100|number:0}}%</td>
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

module.factory 'resultsService', ->
  results = {my: [], enemy: []}
  return results

window.MainController = ($scope, unitsService, resultsService) ->
  $scope.$on 'unitsChanged', ->
    myUnits = (unit.hp for unit in unitsService.my)
    enemyUnits = (unit.hp for unit in unitsService.enemy)
    for arr in [myUnits, enemyUnits]
      firstZero = arr.length
      for i in [arr.length..1]
        if arr[i] == 0
          firstZero = i
        else
          break
      arr.splice(firstZero, arr.length - firstZero)
    console.log enemyUnits
    console.log myUnits
    myIndex = enemyUnits.length
    results = simulate(myUnits, enemyUnits, [1, 1, 1], [false, false, false])
    for res, i in results.data.slice(0, myIndex)
      unitsService.enemy[i].results = res
    for res, i in results.data.slice(myIndex)
      unitsService.my[i].results = res
    $scope.$broadcast('newResults')

window.Side = ($scope, unitsService, resultsService) ->
  $scope.init = (which) ->
    $scope.units = unitsService[which]
    $scope.results = resultsService[which]
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