require?("../nodeSetup")()

describe "permission plugin", ->

  beforeEach ->
    if typeof(require) is "function"
      @scaleApp  = require "../../dist/scaleApp"
      @plugin    = require "../../dist/plugins/scaleApp.permission"
      @scaleApp.plugin.register @plugin
    else if window?
      @scaleApp  = window.scaleApp
    @core = new @scaleApp.Core

    # helper method
    @run = (fn, id="id", cb=->) =>

        # create module
        mod = (sb) ->
          init: -> fn sb
          destroy: ->

        # register module
        @core.register id, mod, {i18n: @myLangObj }

        # start that moudle
        @core.start id, callback: cb

  afterEach ->
    @core.stopAll()
    @core.unregisterAll()

  it "provides the method add", ->
    (expect typeof @core.permission.add).toEqual "function"

  it "provides the method remove", ->
    (expect typeof @core.permission.remove).toEqual "function"

  it "rejects all mediator methods if no explicit permission was defined", (done) ->

    test = (sb) ->
      (expect typeof sb.on).toEqual "function"
      (expect sb.on "x", ->).toBe false
      (expect sb.off "x", ->).toBe false
      (expect sb.emit "x").toBe false
      (expect sb.emit "x").toBe false
      done()

    @run test

  it "executes the required methods if a permission was defined", (done) ->

    @core.permission.add "anId", "on", "x"
    @core.permission.add "anId", "on", ["a", "b"]

    test = (sb) ->
      (expect sb.on "y", ->).toEqual false
      (expect sb.on "x", ->).not.toEqual false
      (expect sb.on "a", ->).not.toEqual false
      (expect sb.on "b", ->).not.toEqual false
      (expect sb.emit "x", ->).toBe false
      done()

    @run test, "anId"

  it "rejects a methods if no permission was defined", (done) ->

    @core.permission.add "oo", "on", "x"
    @core.permission.add "ii", "emit", "x"

    test = (sb) ->
      (expect sb.on "x", ->).toBe false
      (expect sb.emit "x", ->).not.toBe false
      done()

    @run test, "ii"

  it "removes a permission", (done) ->

    @core.permission.add "ee", "on", "x"
    @core.permission.add "ee", "emit", ["z", "w"]

    test = (sb) =>
      (expect sb.on "x", ->).not.toBe false
      @core.permission.remove "ee", "on"
      (expect sb.on "x", ->).toBe false
      (expect sb.emit "z", ->).not.toBe false
      @core.permission.remove "ee", "emit", "z"
      (expect sb.emit "z", ->).toBe false
      (expect sb.emit "w", ->).not.toBe false
      done()

    @run test, "ee"
