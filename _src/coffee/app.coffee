$ = require "jquery"
angular = require "angular"
FileUploaderCTR = require "./controlers/FileUploaderCTR.coffee"
require "./directives/components"
require "bootstrapify"

$("#addFiles").bind('click', (e)->
  $(this).parent().find('input[type=file]').trigger('click')
)

angular.module('FileUploaderApp', ['components'])
  .controller('FileUploaderCTR', FileUploaderCTR);