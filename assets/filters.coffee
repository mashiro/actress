mod = angular.module 'actress.filters', []

mod.filter 'minutes', () ->
  (value) ->
    minutes = Math.floor(value / 60)
    seconds = ('00' + Math.floor(value % 60)).substr(-2)
    "#{minutes}:#{seconds}"

