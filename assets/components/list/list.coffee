mod = angular.module 'actress.list', []

mod.controller 'ListController', class ListController
  ### @ngInject ###
  constructor: ($rootScope, @$state, @$stateParams, $location, Encounter) ->
    $rootScope.title ''
    @query = @$stateParams.q

    Encounter.query(page: @$stateParams.page, q: @$stateParams.q)
      .then (result) =>
        result.data
      .then (res) =>
        @next = res.next
        @prev = res.prev

        @zones = []
        zone = null

        for encounter in res.data
          if zone?.name != encounter.zone
            zone = {}
            zone.name = encounter.zone
            zone.encounters = []
            @zones.push zone

          zone.encounters.push encounter

  refresh: () =>
    @$state.go '.', @$stateParams, reload: true

  search: () =>
    @$stateParams = {}
    @$stateParams.q = @query
    @$stateParams.page = null
    @refresh()

  pageChanged: (e, page) =>
    console.log e
    console.log page
    if angular.isNumber(page)
      @$stateParams.page = page
      @refresh()
    else
      e.preventDefault()

