angular.module('gate').service('Auth', [

'Routes', 'util', '$http', '$route',
function(Routes, util, $http, $route) {

  function AuthService(scope) {
    this.currentUser = null
    this.iid = null

    // Intercept routing and check permissions
    scope.$on('$routeChangeStart', function(event, to, from) {
      if (to.skipAuth) return

      if (!this.isIdentified) {
        Routes.gotoLogin()
      } else if (!this.currentUser) {
        Routes.gotoProfile() // signup
      }
    }.bind(this))

    scope.$on('logout', this.logout.bind(this))

    scope.$watch(function() { return this.currentUser }.bind(this), function(user, prevuser) {
      // sync current user with scopes
      scope.currentUser = user
      // Get out of of current view if it requires auth
      if ($route.current && !$route.current.skipAuth) {
        Routes.gotoLogin()
      }
    })

    // init state from data seeds embeded in page by server
    this.iid = window.seeds.iid
    if (window.seeds.userInfo) {
      this.currentUser = window.seed.userInfo
    }
  }

  AuthService.prototype = {
    logout: function() {
      var operation = util.retry(3).times(function() {
        return $http.post('/auth/logout')
      })
      operation.then(function() {
        this.currentUser = null
      }.bind(this))
    },

    get isIdentified() {
      return !!this.iid
    }
  }

  return AuthService
}])