mod = angular.module 'actress.detail', []

mod.controller 'DetailController', class DetailController
  ### @ngInject ###
  constructor: ($rootScope, $stateParams, Encounter) ->
    Encounter.find($stateParams.encid)
      .then (result) =>
        result.data.data
      .then (encounter) =>
        @encounter = encounter
        $rootScope.title encounter.title

