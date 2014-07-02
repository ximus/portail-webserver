'use strict';

angular.module('gate').factory('util', [

'$injector', '$sce', '$q',
function($injector, $sce, $q) {

  var lowercase = angular.lowercase
  return {
    // Memo 8: http://jsperf.com/comparison-of-memoization-implementations/14
    memoize: function (func) {
       var cache = (func.memoize = func.memoize || {})
       return function () {
           var hash = JSON.stringify(arguments);
           return (hash in cache) ? cache[hash] : cache[hash] = func.apply(this, arguments)
       };
     },

    // For parsing directive attributes
    // extracted from angular source
    toBoolean: function(value) {
      if (typeof value === 'function') {
        value = true
      } else if (value && value.length !== 0) {
        var v = lowercase("" + value)
        value = !(v == 'f' || v == '0' || v == 'false' || v == 'no' || v == 'n' || v == '[]')
      } else {
        value = false
      }
      return value
    },

    clone: function(object) {
      return $.extend(new object.constructor(), object)
    },

    // is .times() too much sugar?
    retry: function(times) {
      return {
        times: function(fn) {
          var operation = $q.defer()
          var counter = 0
          function attempt() {
            var promise = fn()
            promise.then(function() {
              operation.resolve.apply(arguments)
            }, function() {
              if (counter < times) {
                attempt()
                counter++
              } else {
                operation.reject.apply(arguments)
              }
            })
          }
          attempt()
          return operation.promise
        }
      }
    },

    capitalize: function(string) {
      var type = typeof string
      if (type === 'boolean' || type === 'number')
        string = string.toString()
      if (typeof string === 'string')
        return string.charAt(0).toUpperCase() + string.slice(1)
      console.warn('[capitalize] cannot captitalize object', object);
      return ''
    },

    // originally http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
    shortuid: function() {
        var S4 = function() {
           return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
        };
        return S4()+S4()+S4();
    },

    injectScopeHelpers: function(scope) {
      // Add to utils
      scope.length = function(el) {
        if (!el) return undefined;
        if (el.length) {
          if (typeof el.length === 'function') {
            return el.length()
          }
          return el.length
        }
        return Object.keys(el).length
      }

      scope.joinKeys = $injector.get('Node').joinKeys
    },

    popupCenter: function(url, width, height, name) {
      var left = (screen.width/2)-(width/2);
      var top = (screen.height/2)-(height/2);
      return window.open(url, name, "menubar=no,toolbar=no,status=no,width="+width+",height="+height+",toolbar=no,left="+left+",top="+top);
    }
  }
}])