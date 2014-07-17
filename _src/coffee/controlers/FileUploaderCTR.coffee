'use strict';

$ = require "jquery"
_ = require "underscore"
tus = require "TUS-Client"

FileUploaderCTR = ($scope)  ->
  queueList = []
  selectedFileList = []
  isObjectDragOver = false

  $scope.fileList = []
  $scope.overwrite = false
  $scope.uploading = false
  $scope.currentFile = null
  $scope.showModal = false
  upload = null
  uploadCheck = null
  options =
    endpoint: 'http://localhost:1080/files/'
    resetBefore: $('#reset_before').prop('checked')
    resetAfter: true

  startCheck = (file, options) ->
    uploadCheck = tus.check(file, options)
      .fail((error, status) ->
        return $scope.stopFileUpload() unless $scope.uploading
        startUpload(file, options)
      )
      .done((url, file) ->
        $scope.showModal = true
        $scope.$apply()
      )

  startUpload = (file, options) ->
    upload = tus.upload(file, options)
      .fail( (error, status) ->
        onUploadStop()
      )
      .progress((e, bytesUploaded, bytesTotal) ->
        try
          onUploadProgress(bytesUploaded, bytesTotal)
        catch e
          console.log(e.message)
      )
      .done((url, file, md5) ->
        onUploadComplete()
      )

  onUploadProgress = (bytesUploaded, bytesTotal) ->
    progress = Math.floor((bytesUploaded / bytesTotal) * 100)
    $scope.currentFile.uploading = true
    $scope.currentFile.progressStyle = "width: " + progress + "%;"
    $scope.$apply()

  onUploadComplete = ->
    $scope.currentFile.uploading = false
    $scope.currentFile.uploaded = true
    return $scope.stopFileUpload() unless $scope.uploading
    $scope.startFileUpload()
    $scope.uploading = queueList.length > 0
    $scope.$apply()

  $scope.handleFileExists = (value)->
    $scope.showModal = false
    if (value)
      startUpload($scope.currentFile, options)
    else
      $scope.stopFileUpload()

  $scope.haveFileAPI = ->
    tus.UploadSupport

  $scope.getValueIf = (variable, upload, stop) ->
    return if variable then stop else upload

  $scope.isSelectedFileListEmpty = ->
    return selectedFileList.length == 0

  $scope.isFileListEmpty = ->
    return $scope.fileList.length == 0

  $scope.isDragDialogVisible = ->
    return $scope.isFileListEmpty() || isObjectDragOver

  $scope.isDragMessageVisible = ->
    return !isObjectDragOver && $scope.haveFileAPI()

  $scope.isDropMessageVisible = ->
    return isObjectDragOver && $scope.haveFileAPI()

  $scope.isUploadEnabled = ->
    return !($scope.isFileListEmpty() || queueList.length == 0)

  $scope.onDrop = (event) ->
    event.preventDefault()
    return false if (!$scope.haveFileAPI())
    isObjectDragOver = false;
    $scope.addFiles(event.dataTransfer.files)

  $scope.onDragOver = ->
    isObjectDragOver = true

  $scope.onDragLeave = ->
    isObjectDragOver = false

  $scope.onFileInputSelection = ->
    $scope.addFiles(event.target.files)

  $scope.addFiles = (fileList) ->
    _.each(fileList, (file) ->
      file.selected = false
      file.uploading = false
      file.uploaded = false
      $scope.fileList.push(file)
      loadImage(file)
    )
    queueList = _.filter($scope.fileList, (file) ->
      return !file.uploaded
    )

  loadImage = (file) ->
    return unless (file.type.match("image.*"))
    reader = new FileReader()
    reader.onload = (event) ->
      file.imageDataAsStyle = "background-image:url(" + event.target.result + ")";
      $scope.$apply();
    reader.readAsDataURL(file)

  $scope.toggleSelection = (file) ->
    file.selected = (if file.selected then false else true)
    if (file.selected)
      selectedFileList.push(file);
    else
      selectedFileList = _.reject(selectedFileList, (f) ->
        return f == file;
      )
    event.stopPropagation()

  $scope.getSelectedFileListLength = ->
    return if selectedFileList.length == 0 then "" else selectedFileList.length.toString() + " ";

  $scope.deselectAll = ->
    _.each(selectedFileList, (file) ->
      file.selected = false
    )
    selectedFileList = []

  $scope.isFileSelected = (file) ->
    return file.selected

  $scope.isFileUploading = (file) ->
    return file.uploading

  $scope.isFileUploaded = (file) ->
    return file.uploaded

  $scope.removeSelectedFiles = ->
    $scope.fileList = _.difference($scope.fileList, selectedFileList)
    selectedFileList = []

  $scope.toggleUpload = ->
    if ($scope.uploading)
      $scope.stopFileUpload()
    else
      $scope.startFileUpload()

  $scope.stopFileUpload = ->
    $scope.uploading = $scope.currentFile.uploading = false
    uploadCheck.stop() if uploadCheck?
    upload.stop() if upload?
    $scope.apply()

  $scope.startFileUpload = ->
    queueList = _.filter($scope.fileList, (file) ->
      return !file.uploaded
    )
    return if (queueList.length == 0)
    $scope.currentFile = _.first(queueList)
    $scope.uploading = $scope.currentFile?
    startCheck($scope.currentFile, options)

module.exports = FileUploaderCTR