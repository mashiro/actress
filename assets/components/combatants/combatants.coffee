mod = angular.module 'actress.combatants', []

mod.controller 'CombatantsController', class CombatantsController
  ### @ngInject ###
  constructor: ($state, $stateParams, @utils, Combatant) ->
    @showAll = $state.includes('detail.swings')

    Combatant.query($stateParams.encid)
      .then (result) =>
        result.data.data
      .then (combatants) =>
        friends = _(combatants).filter((c) => c.ally == 'T' and c.job).sortBy('name').value()
        others = _(combatants).filter((c) => c.ally == 'T' and !c.job).sortBy('name').value()
        enemies = _(combatants).filter((c) => c.ally != 'T').sortBy('name').value()
        @combatants = _(friends).concat(others, enemies).value()

