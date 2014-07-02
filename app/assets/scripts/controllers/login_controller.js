angular.module('gate').controller('LoginCtrl', ['$scope', 'Routes', function($scope, Routes) {
  // Go home if already logged in
  if ($scope.currentUser) {
    Routes.gotoHome()
  }
  // callback from Oauth process
  // response is a user data update for him who logged in
  $scope.$onRootScope('auth_complete', function(event, response) {
    var auth = $scope.auth
    auth.iid = response.iid
    debugger
    if (response.user) {
      auth.currentUser = response.user
      Routes.gotoHome()
    } else {
      debugger
      profileSeedCache(response.iid, response.signupSeed)
      // user needs to setup profile
      Routes.gotoProfile()
    }
  })
}])