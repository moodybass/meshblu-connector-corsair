{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-corsair:index')
tinyColor       = require 'tinycolor2'
keyboard        = require 'corsair-rgb'
schemas         = require '../legacySchemas.json'

class Corsair extends EventEmitter
  constructor: ->
    debug 'Corsair constructed'

  isOnline: (callback) =>
    callback null, running: true

  close: (callback) =>
    debug 'on close'
    callback()

  onMessage: (message) =>
    { topic, devices, fromUuid, payload } = message
    return if '*' in devices
    return if fromUuid == @uuid
    debug 'on message', { topic }

    switch payload.action
      when "allKeys" then @allKey payload.keycolour
      when "singleKey" then @singleKey payload.key, payload.keycolour
      when "blink" then @blink payload.keycolour, payload.secondColor
      when "blinkTime" then @blinkTime payload.keycolour, payload.secondColor, payload.count
      else "error"

  blinkTime: (color, color2, count) =>
    self = @
    do blinky = ->
      self.blink(color, color2)
      count -= 1
      setTimeout blinky, 1500 unless count < 0


  blink: (color, color2) =>
    setTimeout ( =>
      @allKey color
    ), 1000
    @allKey color2

  allKey: (color) =>
      color = tinyColor(color)
   	  color = color.toRgb()
      keyboard.setKeyColor(keyboard.keymap.all, color.r, color.g, color.b)
      keyboard.flushLightBuffer()


  singleKey: (key, color) =>
      color = tinyColor(color)
   	  color = color.toRgb()
      keyboard.setKeyColor(keyboard.keymap.all[key], color.r, color.g, color.b)
      keyboard.flushLightBuffer()

  onConfig: (device) =>
    { @options } = device
    debug 'on config', @options

  start: (device) =>
    { @uuid } = device
    debug 'started', @uuid
    @emit 'update', schemas
    keyboard.initialize()

module.exports = Corsair
