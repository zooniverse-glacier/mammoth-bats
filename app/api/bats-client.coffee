PanoptesClient = require 'panoptes-client'
config = require './config'

client = new PanoptesClient
  appID: config.clientAppID
  host: config.host

module.exports =
  api: client.api

  auth: client.api.auth
