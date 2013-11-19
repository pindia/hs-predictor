module = angular.module( "hs", [] );

class Unit
  constructor: (hp) ->
    this.hp = hp
  modHp: (amt) ->
    this.hp = Math.min(99, Math.max(0, this.hp + amt))


module.directive 'unit', ->
  restrict: 'E'
  scope:
    unit: '=unit'
  template: '''
    <div class="unit" ng-class="{disabled: unit.hp==0}">
        <input type="text" ng-model="unit.hp">
        <div ng-click="unit.modHp(1)">+</div>
        <div ng-click="unit.modHp(-1)">-</div>
    </div>
  '''

module.factory 'unitsService', ->
  units = {my: [new Unit(30), new Unit(0), new Unit(0)], enemy: [new Unit(30), new Unit(2), new Unit(0)]}
  return units

window.MainController = ($scope, unitsService) ->
  $scope.$on 'unitsChanged', ->
    console.log 'change'
    myUnits = (unit.hp for unit in unitsService.my when unit.hp > 0)
    enemyUnits = (unit.hp for unit in unitsService.enemy when unit.hp > 0)
    console.log myUnits
    console.log search(myUnits, enemyUnits, 3, 0)

window.Side = ($scope, unitsService) ->
  $scope.init = (which) ->
    $scope.units = unitsService[which]
  $scope.$watch('units', ->
    $scope.$emit('unitsChanged')
  , true)

#
#
#window.Unit = ($scope) ->
#  $scope.hp = 0
#  $scope.$watch 'hp', ->
#    $scope.hp = Math.min(99, Math.max(0, $scope.hp))
#  $scope.modHp = (amt) ->
#    $scope.hp += amt
#    #$scope.hp = Math.max(0, $scope.hp + amt)