//= require ./vendor/jquery/dist/jquery.js
//= require ./vendor/angular/angular.js
//= require ./vendor/angular-route/angular-route.js

//= require ./app
//= require_tree ./controllers
//= require_tree ./directives
//= require_tree ./decorators
//= require_tree ./services


// NOTE: Added a scripts/vendor symlink to vendor to get over a sprockets misunderstanding


console.log("RESTART", Date.now().toString())

Array.wrap = function(obj) {
  if (obj instanceof Array) {
    return obj
  }
  return [obj]
}