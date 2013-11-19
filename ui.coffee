window.Unit = ($scope) ->
  $scope.hp = 0
  $scope.$watch 'hp', ->
    $scope.hp = Math.min(99, Math.max(0, $scope.hp))
  $scope.modHp = (amt) ->
    $scope.hp += amt
    #$scope.hp = Math.max(0, $scope.hp + amt)