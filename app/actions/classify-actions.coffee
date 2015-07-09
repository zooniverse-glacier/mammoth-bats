Reflux = require 'reflux'
PanoptesClient = require 'panoptes-client'

config = require '../api/config'

ClassifyActions = Reflux.createActions([
  "getProject",
  "createNewClassification"
])

module.exports = ClassifyActions