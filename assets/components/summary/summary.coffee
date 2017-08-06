mod = angular.module 'actress.summary', []

mod.controller 'SummaryController', class SummaryController
  ### @ngInject ###
  constructor: (@$scope, $stateParams, $q, $filter, ngTableParams, @utils, @Settings, @Encounter, @Combatant) ->
    self = @
    orderBy = $filter 'orderBy'

    @$scope.dspChartConfig =
      options:
        tooltip:
          shared: true
          valueDecimals: 2
        legend:
          align: 'right'
          verticalAlign: 'top'
        colors: ['#F45B5B', '#90EE7E']
        title:
          text: 'Summary'
        credits:
          enabled: false
      yAxis: [
        title:
          text: 'DPS'
      ,
        title:
          text: 'HPS'
        opposite: true
      ]

    @Encounter.find($stateParams.encid)
      .then (result) =>
        result.data.data
      .then (encounter) =>
        @encounter = encounter

    @includeEnemies = false
    @$scope.$watch (() => @includeEnemies), (newValue, oldValue) =>
      @reload() if newValue != oldValue

    @tableParams = new ngTableParams({
        sorting:
          encdps: 'desc'
      }, {
        counts: []
        getData: ($defer, params) =>
          @$scope.dspChartConfig.loading = true
          @getCombatants($stateParams.encid, @includeEnemies).then (combatants) =>
            @updateDSPChart combatants

            if sorting = params.sorting()
              key = Object.keys(sorting)[0]
              order = sorting[key] is "desc"
              getter = (obj) =>
                v = obj[key]
                n = parseFloat(v)
                n = -1 if key.match(/perc$/) and isNaN(n)
                if isNaN(n) then v else n
              combatants = orderBy combatants, getter, order

            $defer.resolve combatants
            return
          return
      })

  getCombatants: (encid, includeEnemies) =>
    @Combatant.query(encid)
      .then (result) =>
        result.data.data
      .then (combatants) =>
        combatants = _.filter(combatants, (c) -> c.ally is 'T') unless includeEnemies
        combatants

  updateDSPChart: (combatants, noUpdate = false) =>
    unless angular.equals(@lastCombatants, combatants)
      combatants = _.sortBy combatants, (c) => -c.encdps
      chart = @$scope.dspChartConfig

      chart.xAxis = [
        categories: combatants.map (c) => c.name
        crosshair: true
      ]

      chart.series = [
        name: 'DPS'
        type: 'column'
        yAxis: 0
        data: combatants.map (c) => c.encdps
      ,
        name: 'HPS'
        type: 'column'
        yAxis: 1
        data: combatants.map (c) => c.enchps
      ]

    @lastCombatants = combatants
    chart.loading = false

  reload: () =>
    @tableParams.reload()

