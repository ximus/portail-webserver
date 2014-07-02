angular.module('gate').service('Routes', ['$location', function($location) {
  function goto (path) {
    // only go if not currently there
    if ($location.path() !== path) {
      $location.path(path)
    }
  }
  return {
    gotoLogin: function() {
      goto('/login')
    },
    gotoHome: function() {
      goto('/')
    },
    gotoProfile: function() {
      goto('/profile')
    }
  }
}])