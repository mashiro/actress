app = angular.module 'actress', [
  'ui.router'
  'ngAnimate'
  'angular-loading-bar'
  'angularMoment'
  'ngTable'
  'highcharts-ng'

  'actress.models'
  'actress.filters'
  'actress.services'
  'actress.directives'

  'actress.list'
  'actress.detail'
  'actress.summary'
  'actress.combatants'
  'actress.damage'
  'actress.swings'
]

app.constant 'Settings',
  TITLE: 'ACTress'
  ICON_BASE_URL: 'https://hibiyasleep.github.io/kagerou/share/img/class'

app.config ($locationProvider, $stateProvider, $urlRouterProvider) ->
  $locationProvider.html5Mode true
  $urlRouterProvider.otherwise '/'
  $stateProvider
    .state 'list',
      url: '/?q&page'
      template: require('components/list/list.html')
      controller: 'ListController as list'
      params:
        q:
          value: ''
          squash: true
        page:
          value: ''
          squash: true

    .state 'detail',
      url: '/:encid'
      abstract: true
      template: require('components/detail/detail.html')
      controller: 'DetailController as detail'
    .state 'detail.summary',
      url: ''
      template: require('components/summary/summary.html')
      controller: 'SummaryController as summary'

    .state 'detail.damage',
      url: '/damage'
      template: require('components/combatants/combatants.html')
      controller: 'CombatantsController as combatants'
    .state 'detail.damage.detail',
      url: '/:name'
      template: require('components/damage/damage.html')
      controller: 'DamageController as damage'

    .state 'detail.swings',
      url: '/swings'
      template: require('components/combatants/combatants.html')
      controller: 'CombatantsController as combatants'
    .state 'detail.swings.detail',
      url: '/:name'
      template: require('components/swings/swings.html')
      controller: 'SwingsController as swings'


app.config (cfpLoadingBarProvider) ->
  cfpLoadingBarProvider.parentSelector = '#main'

app.run (amMoment) ->
  amMoment.changeLocale 'ja'

app.controller 'AppController', class AppController
  ### @ngInject ###
  constructor: ($rootScope, $location, Settings) ->
    _title = Settings.TITLE
    $rootScope.title = (title) ->
      if angular.isString(title)
        if title.length > 0
          _title = "#{title} - #{Settings.TITLE}"
        else
          _title = Settings.TITLE
      _title

    @ogp =
      title: () => $rootScope.title()
      type: () => 'website'
      url: () => $location.absUrl()

