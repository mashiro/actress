mod = angular.module 'actress.services', []

mod.service 'utils', class Utils
  ### @ngInject ###
  constructor: (@Settings) ->
  test: () => console.log @Settings

  iconUrl: (combatant) =>
    name = combatant.job
    name = combatant.name if name == ''
    name = name.toLowerCase()
    "#{@Settings.ICON_BASE_URL}/images/default/#{name}.png"

  errIconUrl: () =>
    "#{@Settings.ICON_BASE_URL}/images/error.png"

  toSeconds: (s) =>
    Date.parse(s) / 1000

  checkSwingType: (swing, types...) =>
    types.indexOf(swing.swingtype) >= 0

  isAA: (swing) => @checkSwingType(swing, 1)
  isWS: (swing) => @checkSwingType(swing, 2)
  isHeal: (swing) => @checkSwingType(swing, 10)
  isHoT: (swing) => @checkSwingType(swing, 11)
  isDoT: (swing) => @checkSwingType(swing, 20)
  isBuff: (swing) => @checkSwingType(swing, 21)
  isAttack: (swing) => @isAA(swing) or @isWS(swing) or @isDoT(swing)

