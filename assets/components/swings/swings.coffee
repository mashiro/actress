mod = angular.module 'actress.swings', []

mod.controller 'SwingsController', class SwingsController
  ### @ngInject ###
  constructor: (@$scope, @$stateParams, @$q, @$filter, @utils, @Swing, @ngTableParams) ->
    orderBy = @$filter 'orderBy'

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

  reload: =>
    @tableParams.reload()

  getSwings: (encid, name) =>
    @Swing.query(encid, name: name).then (res) =>
      swings = res.data.data
      check = (a, b) => !a or (a and b)

      _(swings)
        .filter (swing) => check(@utils.isAA(swing), @with.aa)
        .filter (swing) => check(@utils.isWS(swing), @with.ws)
        .filter (swing) => check(@utils.isDoT(swing), @with.dot)
        .filter (swing) => check(@utils.isHeal(swing), @with.heal)
        .filter (swing) => check(@utils.isHoT(swing), @with.hot)
        .filter (swing) => check(@utils.isBuff(swing), @with.buff)
        .value()

