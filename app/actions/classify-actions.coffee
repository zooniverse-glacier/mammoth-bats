Reflux = require 'reflux'
PanoptesClient = require 'panoptes-client'

config = require '../api/config'

ClassifyActions = Reflux.createActions
  children: ['fetchWorkflow']


module.exports = ClassifyActions