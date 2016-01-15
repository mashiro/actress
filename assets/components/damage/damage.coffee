mod = angular.module 'actress.damage', []

mod.controller 'DamageController', class DamageController
  ### @ngInject ###
  constructor: (@$scope, @$stateParams, @$q, @$timeout, @$filter, @$location, @utils, @Encounter, @Combatant, @Swing) ->
    minutesFilter = @$filter('minutes')
    numberFilter = @$filter('number')
    self = @

    @$scope.damageChartConfig =
      options:
        chart:
          type: 'area'
        tooltip:
          shared: true
          valueDecimals: 2
        title:
          text: 'Damage'
        credits:
          enabled: false
      series: []
      xAxis:
        crosshair: true
        labels:
          formatter: () -> minutesFilter(@value)
      yAxis:
        title:
          text: 'DPS'

    @onLoad()

  onLoad: () =>
    chart = @$scope.damageChartConfig
    chart.loading = true

    promises =
      encounter: @Encounter.find(@$stateParams.encid)
      combatants: @Combatant.query(@$stateParams.encid)
      swings: @Swing.query(@$stateParams.encid)

    @$q.all(promises)
      .then (result) =>
        @encounter = result.encounter.data.data
        @combatants = result.combatants.data.data
        @swings = result.swings.data.data
        name = @$stateParams.name
        combatant = _(@combatants).find (c) => c.name is name
        @calcDPSPerCombatant @encounter, @combatants, @swings, combatant if combatant
      .then (serieses) =>
        chart.series = serieses or []
        chart.loading = false

  calcDPSPerCombatant: (encounter, combatants, swings, combatant) =>
    encounterStartTime = @utils.toSeconds encounter.starttime
    encounterEndTime = @utils.toSeconds encounter.endtime
    totalSeconds = encounterEndTime - encounterStartTime

    swingsGroup = _(swings)
      .filter((swing) => @utils.isAttack(swing) and swing.attacker is combatant.name)
      .groupBy((swing) => swing.victim)
      .value()

    result = []

    for name, swings of swingsGroup
      victim = _(combatants).find (c) => c.name is name
      victim.starttime ||= encounter.starttime
      victim.endtime ||= encounter.endtime

      elapsedTime = 0
      swing = swings.shift()
      swingTime = @utils.toSeconds(swing.stime) - encounterStartTime if swing
      startTime = @utils.toSeconds(victim.starttime) - encounterStartTime
      endTime = @utils.toSeconds(victim.endtime) - encounterStartTime
      totalDamage = 0

      series = {name: name, data: []}

      while elapsedTime <= totalSeconds
        if swing and swingTime <= elapsedTime
          totalDamage += swing.damage
          swing = swings.shift()
          swingTime = @utils.toSeconds(swing.stime) - encounterStartTime if swing
        else
          dps = null
          fact = elapsedTime - startTime

          if startTime <= elapsedTime and elapsedTime <= endTime and fact >= 3
            dps = totalDamage / fact

          series.data.push dps
          elapsedTime += 1

      result.push series

    result

#       for combatant in $scope.combatants
#         totalDamages[combatant.name] = 0
#         dpsData[combatant.name] = []
#
#         swings = result.data.data
#         _swings = angular.copy swings
#
#         $scope.changeCombatant = (combatant) =>
#           data = calcDPSPerCombatant $scope.encounter, $scope.combatants, _swings, combatant
#           console.log data
#
#           $scope.chartConfig =
#             options:
#               chart:
#                 type: 'area'
#               tooltip:
#                 shared: true
#             title:
#               text: 'Damage'
#             credits:
#               enabled: false
#              xAxis:
#                crosshair: true
#              yAxis:
#                title:
#                  text: 'DPS'
#             series: data
#
#         elapsedTime = 0
#         swing = swings.shift()
#         swingTime = @utils.toSeconds(swing.stime) - startTime
#
#         while elapsedTime <= totalSeconds
#           if swingTime <= elapsedTime
#             if @isAttack swing
#               totalDamages[swing.attacker] += swing.damage
#             swing = swings.shift()
#             swingTime = @utils.toSeconds(swing.stime) - startTime
#           else
#             for combatant in $scope.combatants
#               totalDamage = totalDamages[combatant.name] || 0
#               dps = (totalDamage / elapsedTime) || 0
#               dpsData[combatant.name].push dps
#             elapsedTime += 1
#
#         $scope.dpsData = dpsData
#
#     window.encounter = $scope.encounter
#     window.moment = moment
#
#     console.log endTime - startTime
