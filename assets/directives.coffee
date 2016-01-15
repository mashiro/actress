mod = angular.module 'actress.directives', []

mod.directive 'errSrc', () ->
  (scope, element, attrs) ->
    element.bind 'error', () ->
      if attrs.src != attrs.errSrc
        attrs.$set 'src', attrs.errSrc
