path = require 'path'
MeshbluHTTP = require 'meshblu-http'
MeshbluConfig = require 'meshblu-config'
meshblu = require 'meshblu'

describe 'REST', ->
  before (done) ->
    filename = path.join __dirname, 'meshblu.json'
    @config = new MeshbluConfig(filename: filename).toJSON()
    @meshblu = new MeshbluHTTP @config
    @conx = meshblu.createConnection
      server : @config.server
      port   : @config.port
      uuid   : @config.uuid
      token  : @config.token

    @conx.on 'ready', => done()
    @conx.on 'notReady', done

  it 'should get here', ->
    expect(true).to.be.true

  describe '/devices', ->
    describe 'when called with a valid request', ->
      beforeEach (done) ->
        @meshblu.devices {}, =>
          @conx.once 'message', (@message) =>
            done()

      it 'should send a "devices" message', ->
        expect(@message.topic).to.deep.equal 'devices'
        expect(@message.payload).to.deep.equal {
          fromUuid: "66b2928b-a317-4bc3-893e-245946e9672a"
          request: {}
        }

    describe 'when called with an invalid request', ->
      beforeEach (done) ->
        @meshblu.devices {uuid: 'invalid-uuid'}, =>
          @conx.once 'message', (@message) =>
            done()

      it 'should send a "devices-error" message', ->
        expect(@message.topic).to.deep.equal 'devices-error'
        expect(@message.payload).to.deep.equal {
          fromUuid: "66b2928b-a317-4bc3-893e-245946e9672a"
          error: "Devices not found"
          request:
            uuid: 'invalid-uuid'
        }
