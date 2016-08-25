BUILD_PATH = 'lib'

module.exports = (grunt) ->

  # Project configuration
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      build:
        options:
          bare: true
        files: [
          expand: true
          cwd: 'src'
          src: ['**/*.coffee']
          dest: '.'
          ext: '.js'
        ]

    jsdoc:
      build:
        src: ['./index.js', './README.md']
        options:
          destination : 'docs'
          template : 'node_modules/ink-docstrap/template'
          configure : './conf.json'
          access: 'all'
          package: './package.json'

  # Dependencies
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-jsdoc'

  # Aliases
  grunt.registerTask 'build', [
    'coffee:build'
    'jsdoc'
  ]

  grunt.registerTask 'default', [
    'build'
  ]
