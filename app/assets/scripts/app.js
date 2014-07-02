'use strict';

var app = angular.module('gate', ['ngRoute'])

function profileSeedCache(iid, val) {
  if (!id) { console.error('profileSeedCache: missing iid'); return }
  key = "user-seed-cache:"+iid
  if (arguments.legnth === 1) {
    return JSON.parse(localStorage.getItem(key))
  } else {
    return localStorage.setItem(key, JSON.stringify(val))
  }
}

app.config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider){
  $routeProvider.when('/login',
    {
      templateUrl: '/views/login.html',
      controller:  'LoginCtrl',
      skipAuth: true
    }
  ).when('/logout',
    {

    }
  ).when('/gate',
    {
      templateUrl: '/views/gate.html',
      controller:  'GateCtrl'
    }
  ).when('/profile',
    {
      templateUrl: '/views/profile.html',
      controller:  'ProfileCtrl'
    }
  ).when('/users',
    {
      templateUrl: '/views/users.html',
      controller:  'UsersCtrl'
    }
  ).otherwise({
    redirectTo: '/gate'
  })

 $locationProvider.html5Mode(true)
}])

app.run(['$rootScope', 'util', 'Auth', function($rootScope, util, Auth) {
  $rootScope.auth = new Auth($rootScope)
}])

window.authPopupCallback = function(user_info) {
  var scope = angular.element('[ng-app]').scope()
  scope.$apply(function() {
    scope.$emit('auth_complete', user_info)
  })
}