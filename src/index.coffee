vsprintf = require('sprintf-js').vsprintf
q = require 'q'
https = require 'https'
query = require 'querystring'

module.exports = class InstaJS

  ###*
  # @var {Object} _defaults - Default options
  # @memberof InstaJS
  # @access private
  ###
  _defaults =
    limit: 10
    timeout: 15000
    access_token: undefined


  _options = {}

  ###*
  # @var {String} _API_BASE - Host of the Instagram API
  # @memberof InstaJS
  # @access private
  ###
  _API_BASE = 'api.instagram.com'

  ###*
  # @var {String} _API_PORT - Port of the Instagram API
  # @memberof InstaJS
  # @access private
  ###
  _API_PORT = 443

  ###*
  # @method _setAccessToken
  # @description Setter for the access_token
  # @memberof InstaJS
  #
  # @access private
  ###
  _setAccessToken = (token) ->
    if typeof token is 'string'
      _options.access_token = token
    else
      throw new Error 'access_token must be string.
      [access_token is ' + typeof token + ']'

    return

  ###*
  # @method _getAccessToken
  # @description Getter for the access_token
  # @memberof InstaJS
  #
  # @access private
  #
  # @return {String} output - Access_token
  ###
  _getAccessToken = () ->
    _options.access_token

  ###*
  # @method _call
  # @description Prepares the request and calls the Instagram api as well as it
  # builds the result and errors to be returned to the promise or callback
  # @memberof InstaJS
  #
  # @access private
  #
  # @param {String} method - HTTP method (GET, POST, DELETE)
  # @param {String} endpoint - Instagram API endpoint to be called
  # @param {Object} params - Params for the API call
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback
  ###
  _call = (method, endpoint, params = {}, callback) ->
    result = ''

    params.access_token = _getAccessToken()

    if params.access_token is undefined
      callback('Missing access_token')

    if !params.count
      params.count = _options.limit

    options =
      host: _API_BASE
      port: _API_PORT
      method: method
      path: '/v1/' + endpoint +
      (if method isnt 'POST' then '?' + query.stringify(params) else '')
      headers: {
        'Content-Type': 'application/json'
      }

    if method is 'POST'
      data = query.stringify(params)
      options.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      options.headers['Content-Length'] = data.length


    req = https.request options, (res) ->
      res.setEncoding 'utf8'

      res.on 'data', (chunk) ->
        result += chunk
        return

      res.on 'end', ->
        limit = parseInt(res.headers['x-ratelimit-limit'], 10) || 0
        remaining = parseInt(res.headers['x-ratelimit-remaining'], 10) || 0

        try
          result = JSON.parse result
        catch err
          return callback err, result, limit, remaining

        return callback null, result, limit, remaining
      return

    if data
      req.write data

    req.setTimeout _options.timeout, () ->
      req.abort()
      return

    req.on 'error', (err) ->
      return callback err

    req.end()
    return

  ###*
  # @method _promise
  # @description Build the promise to be returned from a API call without callback
  # @memberof InstaJS
  #
  # @access private
  #
  # @param {Object} deferred
  #
  # @return {Function} output - Returnes promise
  ###
  _promise = (deferred) ->
    return (err, res, limit, remaining) ->
      if !err and res.meta.code isnt 200
        deferred.reject res.meta
      else if !err and res.meta
        deferred.resolve({
          code: res.meta.code
          data: res.data
          count: limit
          remaining: remaining
        })
      else if !err and !res.meta
        deferred.reject res
      else
        deferred.reject err
      return

  ###*
  # @method _changeRelationship
  # @description Changes the relationship between access_token owner and
  # user by action (follow, unfollow, ignore, approve)
  # @memberof InstaJS
  #
  # @access private
  #
  # @param {String} id - Can be a user id or 'self'
  # @param {String} action - Can be 'follow', 'unfollow', 'ignore' and 'approve'
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  _changeRelationship = (id, action, callback) ->
    callback = callback or action or id or undefined

    url = vsprintf 'users/%s/relationship', [id]

    _call 'POST', url, {action: action}, callback

  ###*
  # @class InstaJS
  # @constructs InstaJS
  # @description Create a new InstaJS object.
  # @classdesc Class wrapping the Instagram API into JavaSctipt Class
  #
  # @param {Object} opts - Options for the api calls
  # @property {String} opts.access_token - Token to authenticate at
  # instragam api
  # @property {Number} opts.limit - The limit to use for api call results
  # @property {Number} opts.timeout - Timeout for api call
  ###
  constructor: (opts) ->
    if typeof opts isnt 'string'
      _options = _.merge {}, _defaults, opts
    else
      _options = _defaults
      _setAccessToken opts

  ###*
  # @method getUser
  # @description Get information about a user.
  # @memberof InstaJS
  # @access public
  #
  # @example <caption>Get user info</caption>
  #   new InstaJS().getUser('3019302352', function(err, user){
  #     //do something...
  #   });)
  #
  # @param {String} user - Can be a user id or 'self'
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  getUser: (user, callback) ->
    callback = callback or user or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'users/%s/', [user]

    _call 'GET', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method getTag
  # @description Get information about a tag.
  # @memberof InstaJS
  #
  # @example <caption>Get tag info</caption>
  #   new InstaJS().getTag('photooftheday', function(err, user){
  #     //do something...
  #   });)
  #
  # @param {String} tag - Tag name to get info
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  getTag: (tag, callback) ->
    callback = callback or tag or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'tags/%s/', [tag]

    _call 'GET', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method getLocation
  # @description Get information about a location.
  # @memberof InstaJS
  #
  # @example <caption>Get location info</caption>
  #   new InstaJS().getLocation('123', function(err, user){
  #     //do something...
  #   });)
  #
  # @param {String} location - Location id to get info
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  getLocation: (location, callback) ->
    callback = callback or location or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'locations/%s/', [location]

    _call 'GET', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method recentlyLiked
  # @description Get recently liked media of access_token owner.
  # @memberof InstaJS
  #
  # @example <caption>Recently liked media</caption>
  #   new InstaJS().recentlyLiked({count: 10}, function(err, media){
  #     //do something...
  #   });
  #
  # @param {Object} opts - Options for api call
  # @param {Function} callback - Callback function to be called
  # @property {Number} opts.count - Limit of returned media objects
  # @property {Number} opts.max_like_id - Get media liked before this id
  #
  # @return {Function} output - Returnes callback or promise
  ###
  recentlyLiked: (opts, callback) ->
    callback = callback or opts or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = 'users/self/media/liked'

    _call 'GET', url, opts, callback

    if deferred then deferred.promise

  ###*
  # @method recentlyPosted
  # @description Get recently posted media of user.
  # @memberof InstaJS
  #
  # @example <caption>Recently posted media</caption>
  #   new InstaJS().recentlyPosted('1245', {count: 10}, function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} id - Can be 'self' or a user id
  # @param {Object} opts - Options for api call
  # @param {Function} callback - Callback function to be called
  # @property {Number} opts.count - Limit of returned media objects
  # @property {Number} opts.max_id - Get media posted before this id
  # @property {Number} opts.min_id - Get media posted after this id
  #
  # @return {Function} output - Returnes callback or promise
  ###
  recentlyPosted: (id, opts, callback) ->
    callback = callback or opts or id or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'users/%s/media/recent', [id]

    _call 'GET', url, opts, callback

    if deferred then deferred.promise

  ###*
  # @method findUsersByName
  # @description Search user by username.
  # @memberof InstaJS
  #
  # @example <caption>Search a user</caption>
  #   new InstaJS().findUsersByName('rico_race_director', function(err, media){
  #     //do something...
  #   });)
  #
  # @param {String} name - Username to search for
  # @param {Object} opts - Options for api call
  # @param {Function} callback - Callback function to be called
  # @property {Number} opts.count - Limit of returned users
  #
  # @return {Function} output - Returnes callback or promise
  ###
  findUsersByName: (name, opts, callback) ->
    callback = callback or opts or name or undefined

    if typeof name is 'string'
      opts.q = name

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = 'users/search'

    _call 'GET', url, opts, callback

    if deferred then deferred.promise

  ###*
  # @method findTagsByName
  # @description Search tags by name.
  # @memberof InstaJS
  #
  # @example <caption>Search a tag</caption>
  #   new InstaJS().findTagsByName('photoof', function(err, media){
  #     //do something...
  #   });)
  #
  # @param {String} name - Tag name to search
  # @param {Object} opts - Options for api call
  # @param {Function} callback - Callback function to be called
  # @property {Number} opts.count - Limit of returned tags
  #
  # @return {Function} output - Returnes callback or promise
  ###
  findTagsByName: (name, opts = {}, callback) ->
    callback = callback or opts or name or undefined

    if typeof name is 'string'
      opts.q = name

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = 'tags/search'

    _call 'GET', url, opts, callback

    if deferred then deferred.promise

  ###*
  # @method findLocationsByGeo
  # @description Get locations around specific geo coordinate.
  # @memberof InstaJS
  #
  # @example <caption>Get locations</caption>
  #   new InstaJS().findLocationsByGeo('48.858844', '2.294351', function(err, user){
  #     //do something...
  #   });)
  #
  # @param {String} lat - Latitute of location
  # @param {String} lng - Longitute of location
  # @param {Object} opts - Options for api call
  # @param {Function} callback - Callback function to be called
  # @property opts {Number} distance - Area around coordinate in meters (min=0, max=750)
  #
  # @return {Function} output - Returnes callback or promise
  ###
  findLocationsByGeo: (lat, lng, opts, callback) ->
    callback = callback or opts or lat or lng or undefined

    if typeof lat is 'string'
      opts.lat = lat

    if typeof lng is 'string'
      opts.lng = lng

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = 'locations/search'

    _call 'GET', url, opts, callback

    if deferred then deferred.promise

  ###*
  # @method postsByUser
  # @description Get recently posted media of a user.
  # @memberof InstaJS
  #
  # @example <caption>Recent posts by user</caption>
  #   new InstaJS().postsByUser('self', {count: 10}, function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} user - Can be 'self' or a user id
  # @param {Object} opts - Options for api call
  # @param {Function} callback - Callback function to be called
  # @property opts {Number} count - Limit of returned media objects
  # @property opts {Number} max_id - Get media before this id
  # @property opts {Number} min_id - Get media after this id
  #
  # @return {Function} output - Returnes callback or promise
  ###
  postsByUser: (user, opts, callback) ->
    callback = callback or opts or user or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'users/%s/media/recent/', [user]

    _call 'GET', url, opts, callback

    if deferred then deferred.promise

  ###*
  # @method postsByTag
  # @description Get recent media by hashtag
  # @memberof InstaJS
  #
  # @example <caption>Recent posts by hastag</caption>
  #   new InstaJS().postsByTag('instajs', {count: 10}, function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} user - Can be 'self' or a user id
  # @param {Object} opts - Options for api call
  # @param {Function} callback - Callback function to be called
  # @property opts {Number} count - Limit of returned media objects
  # @property opts {Number} max_tag_id - Get media before this tag id
  # @property opts {Number} min_tag_id - Get media after this tag id
  #
  # @return {Function} output - Returnes callback or promise
  ###
  postsByTag: (tag, opts, callback) ->
    callback = callback or opts or tag or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'tags/%s/media/recent', [tag]

    _call 'GET', url, opts, callback

    if deferred then deferred.promise

  ###*
  # @method postsByLocationId
  # @description Get recent media by location id
  # @memberof InstaJS
  #
  # @example <caption>Recent posts by location</caption>
  #   new InstaJS().postsByLocationId('1', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} location - Must be location id
  # @param {Object} opts - Options for api call
  # @param {Function} callback - Callback function to be called
  # @property opts {Number} max_id - Get media before this id
  # @property opts {Number} min_id - Get media after this id
  #
  # @return {Function} output - Returnes callback or promise
  ###
  postsByLocationId: (location, opts, callback) ->
    callback = callback or opts or location or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'locations/%s/media/recent', [location]

    _call 'GET', url, opts, callback

    if deferred then deferred.promise

  ###*
  # @method postsByGeoLocation
  # @description Get recent media by geo location
  # @memberof InstaJS
  #
  # @example <caption>Recent posts by geo location</caption>
  #   new InstaJS().postsByGeoLocation('48.858844', '2.294351', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} lat - Latitute of location
  # @param {String} lng - Longitute of location
  # @param {Object} opts - Options for api call
  # @param {Function} callback - Callback function to be called
  # @property opts {Number} distance - Area around coordinate in meters (min=0, max=750)
  #
  # @return {Function} output - Returnes callback or promise
  ###
  postsByGeoLocation: (lat, lng, opts, callback) ->
    callback = callback or opts or lat or lng or undefined
    if typeof opts isnt 'object'
      opts = {}

    if typeof lat is 'string'
      opts.lat = lat

    if typeof lng is 'string'
      opts.lng = lng

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = 'media/search'

    _call 'GET', url, opts, callback

    if deferred then deferred.promise

  ###*
  # @method postById
  # @description Get media by id
  # @memberof InstaJS
  #
  # @example <caption>Get post by id</caption>
  #   new InstaJS().postById('12678491', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} id - Id of post
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  postById: (id, callback) ->
    callback = callback or id or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'media/%s', [id]

    _call 'GET', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method postBShortcode
  # @description Get media by shortcode
  # @memberof InstaJS
  #
  # @example <caption>Get post by shortcode</caption>
  #   new InstaJS().postByShortcode('tsxp1hhQTG', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} shortcode - Shortcode of post
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  postByShortcode: (shortcode, callback) ->
    callback = callback or shortcode or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'media/shortcode/%s', [shortcode]

    _call 'GET', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method getFollows
  # @description Get list of users the access_token owner follows
  # @memberof InstaJS
  #
  # @example <caption>Get followed users</caption>
  #   new InstaJS().getFollows(function(err, media){
  #     //do something...
  #   });
  #
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  getFollows: (callback) ->
    callback = callback or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = 'users/self/follows'

    _call 'GET', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method getFollowers
  # @description Get list of users which follow the access_token owner
  # @memberof InstaJS
  #
  # @example <caption>Get follow users</caption>
  #   new InstaJS().getFollowers(function(err, media){
  #     //do something...
  #   });
  #
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  getFollowers: (callback) ->
    callback = callback or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = 'users/self/followed-by'

    _call 'GET', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method getRequestedBy
  # @description Get list of users which want to follow the access_token owner
  # @memberof InstaJS
  #
  # @example <caption>Get open request list</caption>
  #   new InstaJS().getRequestedBy(function(err, media){
  #     //do something...
  #   });
  #
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  getRequestedBy: (callback) ->
    callback = callback or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = 'users/self/requested-by'

    _call 'GET', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method getRelationship
  # @description Get relationship to user with given id
  # @memberof InstaJS
  #
  # @example <caption>Get relationship with user</caption>
  #   new InstaJS().getRelationship('1237', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} id - Id of user to get relationship
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  getRelationship: (id, callback) ->
    callback = callback or id or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'users/%s/relationship', [id]

    _call 'GET', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method follow
  # @description Follow user with id
  # @memberof InstaJS
  #
  # @example <caption>Follow user</caption>
  #   new InstaJS().follow('131231231', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} id - Id of user to follow
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  follow: (id, callback) ->
    callback = callback or id or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'users/%s/relationship', [id]

    _changeRelationship id, 'follow', callback

    if deferred then deferred.promise

  ###*
  # @method unfollow
  # @description Unfollow user with id
  # @memberof InstaJS
  #
  # @example <caption>Unfollow user</caption>
  #   new InstaJS().unfollow('131231231', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} id - Id of user to unfollow
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  unfollow: (id, callback) ->
    callback = callback or id or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'users/%s/relationship', [id]

    _changeRelationship id, 'unfollow', callback

    if deferred then deferred.promise

  ###*
  # @method approveRequest
  # @description Approve request to follow by user with id
  # @memberof InstaJS
  #
  # @example <caption>Approve request</caption>
  #   new InstaJS().approveRequest('131231231', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} id - Id of user which requested to allow to follow
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  approveRequest: (id, callback) ->
    callback = callback or id or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'users/%s/relationship', [id]

    _changeRelationship id, 'approve', callback

    if deferred then deferred.promise

  ###*
  # @method ignoreRequest
  # @description Ingore request to follow by user with id
  # @memberof InstaJS
  #
  # @example <caption>Ignore request</caption>
  #   new InstaJS().ignoreRequest('131231231', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} id - Id of user to ignore
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  ignoreRequest: (id, callback) ->
    callback = callback or id or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'users/%s/relationship', [id]

    _changeRelationship id, 'ignore', callback

    if deferred then deferred.promise

  ###*
  # @method like
  # @description Send a like to media by it's id
  # @memberof InstaJS
  #
  # @example <caption>Like a post by id</caption>
  #   new InstaJS().like('12678491', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} id - Id of post to like
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  like: (id, callback) ->
    callback = callback or id or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'media/%s/likes', [id]

    _call 'POST', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method getLikes
  # @description Get recent likes of media by it's id
  # @memberof InstaJS
  #
  # @example <caption>Get recebt likes of a post by id</caption>
  #   new InstaJS().getLikes('12678491', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} id - Id of post to like
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  getLikes: (id, callback) ->
    callback = callback or id or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'media/%s/likes', [id]

    _call 'GET', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method removeLike
  # @description Remove a like of media by it's id
  # @memberof InstaJS
  #
  # @example <caption>Remove a like on post by id</caption>
  #   new InstaJS().removeLike('12678491', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} id - Id of post to remove the like
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  removeLike: (id, callback) ->
    callback = callback or id or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'media/%s/likes', [id]

    _call 'DELETE', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method comment
  # @description Send a comment to media by it's id
  # @memberof InstaJS
  #
  # @example <caption>Comment a post by id</caption>
  #   new InstaJS().comment('12678491', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} id - Id of the post to comment
  # @param {String} comment - Text of the comment to send
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} output - Returnes callback or promise
  ###
  comment: (id, comment, callback) ->
    callback = callback or id or comment or undefined

    if typeof comment is 'string'
      opts =
        text: comment

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'media/%s/comments', [id]

    _call 'POST', url, opts, callback

    if deferred then deferred.promise

  ###*
  # @method getComments
  # @description Get recent comments of media by it's id
  # @memberof InstaJS
  #
  # @example <caption>Get comments of a post by id</caption>
  #   new InstaJS().getComments('12678491', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} id - Id of the post
  # @param {Function} callback - Callback function to be called
  #
  # @return {Function} Returnes callback or promise with a list of comments
  ###
  getComments: (id, callback) ->
    callback = callback or id or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'media/%s/comments', [id]

    _call 'GET', url, null, callback

    if deferred then deferred.promise

  ###*
  # @method removeComment
  # @description Remove a comment from media by it's id and the media id
  # @memberof InstaJS
  #
  # @example <caption>Remove comment of a post by ids</caption>
  #   new InstaJS().removeComment('12678491', '12341', function(err, media){
  #     //do something...
  #   });
  #
  # @param {String} mid - Id of the media which contains comment
  # @param {String} cid - Id of the comment to remove
  # @param {Function} callback - Callback function to be called
  # @return {Function} Callback or promise
  ###
  removeComment: (mid, cid, callback) ->
    callback = callback or cid or mid or undefined

    if typeof callback isnt 'function'
      deferred = q.defer()
      callback = _promise deferred

    url = vsprintf 'media/%s/comments/%s', [mid, cid]

    _call 'delete', url, null, callback

    if deferred then deferred.promise
