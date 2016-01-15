mod = angular.module 'actress.models', []

mod.factory 'Encounter', ($http) ->
  find: (encid) ->
    $http.get "/api/encounters/#{encid}", cache: true
  query: (params) ->
    $http.get '/api/encounters', params: params, cache: true

mod.factory 'Combatant', ($http) ->
  query: (encid) ->
    $http.get "/api/encounters/#{encid}/combatants", cache: true

mod.factory 'Swing', ($http) ->
  query: (encid, params = {}) ->
    $http.get "/api/encounters/#{encid}/swings", params: params, cache: true

