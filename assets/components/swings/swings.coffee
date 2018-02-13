mod = angular.module 'actress.swings', []

mod.controller 'SwingsController', class SwingsController
  ### @ngInject ###
  constructor: (@$scope, @$stateParams, @$q, @$filter, @utils, @Swing, @ngTableParams) ->
    orderBy = @$filter 'orderBy'

    @showAll = @$stateParams.name == 'all'
    @attackers = []

    @with =
      aa: false
      ws: true
      dot: false
      heal: false
      hot: false
      buff: true

    @tableParams = new @ngTableParams({
        sorting:
          stime: 'asc'
      }, {
        counts: []
        getData: ($defer, params) =>
          @getSwings(@$stateParams.encid, @$stateParams.name).then (swings) =>
            if sorting = params.sorting()
              key = Object.keys(sorting)[0]
              order = sorting[key] is "desc"
              getter = (obj) =>
                v = obj[key]
                n = parseFloat(v)
                n = -1 if key.match(/perc$/) and isNaN(n)
                if isNaN(n) then v else n
              swings = orderBy swings, getter, order

            $defer.resolve swings
            return
          return
      })

    @$scope.$watch (() => @with), @reload, true
    @$scope.$watch (() => @attackers), @reload, true

  reload: (newValue, oldValue) =>
    unless _.isEmpty(oldValue)
      @tableParams.reload()

  getSwings: (encid, name) =>
    options = {}
    unless @showAll
      options['name'] = name

    @Swing.query(encid, options).then (res) =>
      swings = res.data.data
      typeFilter = (a, b) => !a or (a and b)

      _swings = _(swings)
        .filter (swing) => typeFilter(@utils.isAA(swing), @with.aa)
        .filter (swing) => typeFilter(@utils.isWS(swing), @with.ws)
        .filter (swing) => typeFilter(@utils.isDoT(swing), @with.dot)
        .filter (swing) => typeFilter(@utils.isHeal(swing), @with.heal)
        .filter (swing) => typeFilter(@utils.isHoT(swing), @with.hot)
        .filter (swing) => typeFilter(@utils.isBuff(swing), @with.buff)

      if @showAll
        if _.isEmpty(@attackers)
          @attackers = _(swings).map (swing) => swing.attacker
            .uniq()
            .map (name) => {name: name, show: false}
            .value()

        _swings = _swings.filter (swing) =>
          _.find(@attackers, (attacker) => attacker.name == swing.attacker)?.show

      _swings.value()


