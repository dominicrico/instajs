# InstaJS
Just another Instagram API wrapper for your NodeJS Project.

## Install
```
npm install --save instajs
```

## Usage
Use InstaJS as you want. You can use classic callbacks or you can use pomises.
```javascript
instajs = require('instajs');

// use it without any options just pass your access_token
var insta = new instajs('[your instagram access_token]')

// or you can pass an object with some additional options
var insta = new instajs({
  timeout: 20000, // timeout for API calls in ms
  limit: 200, // limit for returned objects of the API calls
  access_token: '[your instagram access_token]' //your API  access_token
});

//Usage with promises
insta.getUser('self').then(function(data){
  //do something with data
}).catch(function(err){
  //handle error
});

//Usage with callbacks
insta.getUser('self', function(err, data){
  if (err) {
    //handle error
  }

  //do something with data
});
```

## Documentation
Documentation of all the moethods can be found [here](docs/instajs/0.1.0/InstaJS.html)
