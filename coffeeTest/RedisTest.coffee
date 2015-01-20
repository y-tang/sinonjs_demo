mocha = require('mocha')
chai = require('chai')
sinon = require('sinon')
Redis = require('../server/Redis')

root.expect = chai.expect
chai.should()

describe('sinon', ->
  describe('#spy', ->
    it('wrapper spy', (done) ->
      clientSpy = sinon.spy(Redis, 'client')
      clientSismemberSpy = sinon.spy(Redis.client(), 'sismember')

      KEY = 'key'
      VALUE = {}
      Redis.sismember(KEY, VALUE, (error, isMember) ->
        expect(clientSpy.called).to.be.true
        expect(clientSismemberSpy.calledWith(KEY, VALUE, sinon.match.func)).to.be.true
        expect(clientSismemberSpy.calledOnce).to.be.true
        console.log(clientSismemberSpy.firstCall.args)
#        console.log(clientSismemberSpy.getCall(0).args)
        Redis.client.restore()
        Redis.client().sismember.restore()
        done()
      )
    )

    it('anonymous spy', ->
      clientSismemberSpy = sinon.spy()
      sinon.stub(Redis, 'client').returns({test: clientSismemberSpy})
      Redis.test()
      expect(clientSismemberSpy.calledTwice).to.be.true
      Redis.client.restore()
    )
  )

  describe('#stub', ->
    it('callsArgWith', (done) ->
      sinon.stub(Redis.client(), 'sismember').callsArgWith(2, new Error())
      Redis.sismember('key', {}, (error) ->
        expect(error).to.eql(new Error())
        Redis.client().sismember.restore()
        done()
      )
    )

    it('yields', (done) ->
      sinon.stub(Redis.client(), 'sismember').yields(new Error())
      Redis.sismember('key', {}, (error) ->
        expect(error).to.eql(new Error())
        Redis.client().sismember.restore()
        done()
      )
    )

    it('withArgs', (done) ->
      KEY = 'key'
      VALUE = {}

      sinon.stub(Redis.client(), 'sismember').withArgs(KEY, VALUE).callsArgWith(2, new Error())
      Redis.sismember(KEY, VALUE, (error) ->
        expect(error).to.eql(new Error())
        Redis.client().sismember.restore()
        done()
      )
    )

    it('withArgs different yields', (done) ->
      KEY = 'key'
      VALUE = {}
      KEY1 = 'key1'

      stub = sinon.stub(Redis.client(), 'sismember')
      stub.withArgs(KEY, VALUE).yields(new Error())
      stub.withArgs(KEY1, VALUE).yields(null, 1)
      Redis.sismember(KEY1, VALUE, (error, isMember) ->
        expect(error).to.be.null
        expect(isMember).to.be.true
        Redis.client().sismember.restore()
        done()
      )
    )
  )

  describe('#mock', ->
    it('mock', ->
      mock = sinon.mock(Redis.client())
      mock.expects('test')
      .atLeast(1)
      .atMost(2)
      .on(Redis.client())

      testWithArgsExpectation = mock.expects('testWithArgs')

      testWithArgsExpectation
      .exactly(3)
      .on(Redis.client())
      .withArgs(1)

      Redis.test()
      Redis.testWithArgs(1)

      mock.verify()
    )
  )

  describe('#sandbox', ->
    it('sandbox', (done) ->
      sandbox = sinon.sandbox.create()
      sandbox.stub(Redis.client(), 'sismember').yields(new Error())
      Redis.sismember('key', {}, (error) ->
        expect(error).to.eql(new Error())
        sandbox.restore()
        done()
      )
    )

    it('managed sandbox', sinon.test((done) ->
      @stub(Redis.client(), 'sismember').yields(null, 1)
      Redis.sismember('key', {}, (error, isMemeber) ->
        expect(error).to.be.null
        expect(isMemeber).to.be.true
        done()
      )
    ))
  )
)
