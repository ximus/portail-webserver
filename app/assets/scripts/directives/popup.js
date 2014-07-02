angular.module('gate').directive('popup', [
  'util',
  function(util) {
    return {
      link: function(scope, element, attrs) {
        element.on('click', function(e) {
          util.popupCenter(attrs.href, 600, 400, "Identification");
          e.stopPropagation(); return false;
        })
      }
    }
  }
])