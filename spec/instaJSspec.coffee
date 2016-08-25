InstaJS = require '../src/index'

describe 'InstaJS', ->
  insta = undefined

  expected = [
    'code'
    'data'
    'count'
    'remaining'
  ].sort()

  beforeEach ->
    insta = new InstaJS '3019302352.3499f27.f8c6408f60214ce68feb1e501f0a3320'
  describe 'construction', ->
    it 'should create a new instace of InstaJS', ->
      expect(insta instanceof InstaJS).toBeTruthy

  describe 'get information from Instagram API', ->
    it 'should get the current users info', (done) ->
      insta.getUser('self').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should get infos about a tag', (done) ->
      insta.getTag('photooftheday').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should get infos about a location', (done) ->
      insta.getLocation('123').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should get recently liked media', (done) ->
      insta.recentlyLiked().then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should get recently posted media', (done) ->
      insta.recentlyPosted('self').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

  describe 'find tags, users or locations via Instagram API', ->
    it 'should find users by name', (done) ->
      insta.findUsersByName('rico_race_director', {count: 5}).then (data) ->
        actual = Object.keys(data).sort()
        count = Object.keys(data.data).length
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
        expect(count).toEqual(1)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should find tags by name', (done) ->
      insta.findTagsByName('photo', {count: 5}).then (data) ->
        actual = Object.keys(data).sort()
        count = Object.keys(data.data).length
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
        expect(count).toEqual(5)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should find location by geo coordinate', (done) ->
      insta.findLocationsByGeo('1', '1', {distance: 500}).then (data) ->
        actual = Object.keys(data).sort()
        count = Object.keys(data.data).length
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
        expect(count).not.toBeLessThan(1)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

  describe 'find media via Instagram API', ->
    it 'should find posts by user', (done) ->
      insta.postsByUser('self', {count: 5}).then (data) ->
        actual = Object.keys(data).sort()
        count = Object.keys(data.data).length
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
        expect(count).toEqual(5)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should find posts by tag', (done) ->
      insta.postsByTag('photooftheday', {count: 5}).then (data) ->
        actual = Object.keys(data).sort()
        count = Object.keys(data.data).length
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
        expect(count).toEqual(5)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should find posts by id of location', (done) ->
      insta.postsByLocationId('378268179', {count: 5}).then (data) ->
        actual = Object.keys(data).sort()
        count = Object.keys(data.data).length
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
        expect(count).toEqual(2)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should find posts by geo location', (done) ->
      insta.postsByGeoLocation('50.440277777778',
      '6.9152777777778', {count: 5}).then (data) ->
        actual = Object.keys(data).sort()
        count = Object.keys(data.data).length
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
        expect(count).toEqual(2)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should find a single post by id', (done) ->
      insta.postById('1276878612462880543_3019302352').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should find a single post by shortcode', (done) ->
      insta.postByShortcode('BG4YlU1JMcf').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

  describe 'get follow data via Instagram API', ->
    it 'should list users the owner follows', (done) ->
      insta.getFollows().then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should list users which follow the owner', (done) ->
      insta.getFollowers().then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should list users which want to follow the owner', (done) ->
      insta.getRequestedBy().then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should show the relationship between user with id and owner', (done) ->
      insta.getRelationship('12938').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

  describe 'follow, like and comment via Instagram API', ->
    it 'should follow a user', (done) ->
      insta.follow('1').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should unfollow a user', (done) ->
      insta.unfollow('1').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should approve a request to follow', (done) ->
      insta.approveRequest('1').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should ignore a request to follow', (done) ->
      insta.ignoreRequest('1').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should like a post', (done) ->
      insta.like('1').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should remove a like of post', (done) ->
      insta.removeLike('1').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should show a list of people which liked a post', (done) ->
      insta.getLikes('1').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should post a comment to a post', (done) ->
      insta.comment('1', 'Awesome pic!').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should remove a comment of post', (done) ->
      insta.removeComment('1', '123').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done

    it 'should show a list of comments of a post', (done) ->
      insta.getComments('1').then (data) ->
        actual = Object.keys(data).sort()
        expect(typeof(data)).toBe('object')
        expect(actual).toEqual(expected)
      , (err) ->
        expect(err).toBeDefined()
      .finally done
