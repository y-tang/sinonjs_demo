class Redis
  @client: ->
    unless Redis.redisClient
      redisClass = require("redis")
      Redis.redisClient = redisClass.createClient(6379, 'localhost')
      Redis.redisClient.test = ->
      Redis.redisClient.testWithArgs = (arg) ->
    Redis.redisClient

  @sismember: (key, value, callback) =>
    @client().sismember(key, value, (error, isMember) =>
      if error
        callback(error)
      else
        callback(null, isMember == 1)
    )

  @test: =>
    @client().test()
    @client().test()

  @testWithArgs: (i) =>
    @client().testWithArgs(i)
    @client().testWithArgs(i)
    @client().testWithArgs(i)

exports = module.exports = Redis