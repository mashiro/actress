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
        lastEncounter = null

        for encounter in res.data
          unless @isSameZone lastEncounter, encounter
            zone = {}
            zone.name = encounter.zone
            zone.encounters = []
            @zones.push zone

          lastEncounter = encounter
          zone.encounters.push encounter

  isSameZone: (a, b) =>
    return false if !a or !b
    return false if a.name != b.name
    return false if Math.abs(Date.parse(a.starttime) - Date.parse(b.starttime)) >= (20 * 60 * 1000)
    true

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

