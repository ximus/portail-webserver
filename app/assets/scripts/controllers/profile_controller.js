angular.module('gate').controller('ProfileCtrl', ['$scope', '$http', function($scope, $http) {
  // Go home if auth provider step not run
  if (!$scope.auth.isIdentified) {
    Routes.gotoLogin()
  }

  debugger
  $scope.profile = profileSeedCache($scope.auth.iid) || {}

  $scope.isNewUser = function() {
    return !$scope.currentUser
  }

  $scope.submit = function() {
    // TODO: error path
    $http.put('/profile', {profile: $scope.profile}).success(function(response) {
      var isNewUser = false
      if (!$scope.auth.currentUser) isNewUser = true
      $scope.auth.currentUser = response.data
      if (isNewUser) Routes.gotoHome()
    })
  }
}])