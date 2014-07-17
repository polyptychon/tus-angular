$ = require "jquery"
angular = require "angular"
FileUploaderCTR = require "./controlers/FileUploaderCTR.coffee"
require "./directives/components"
require "bootstrapify"

angular.module('FileUploaderApp', ['components'])
  .controller('FileUploaderCTR', FileUploaderCTR);