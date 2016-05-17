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

    { allKeys, keycolour, key } = payload
    return @singleKey key, keycolour unless allKeys == true
    @allKey keycolour


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
