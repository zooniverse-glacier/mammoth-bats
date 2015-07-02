React = require 'react/addons'
Router = require 'react-router'
{Route, RouteHandler, DefaultRoute, Link} = require 'react-router'
PanoptesClient = require('panoptes-client')
config = require './api/config'

BatsClient = new PanoptesClient
  appID: config.clientAppID
  host: config.host

{api} = BatsClient
{auth} = api

MainHeader = require './partials/main-header'

Main = React.createClass
  displayName: "Main"

  getInitialState: ->
    project: null
    user: null

  componentDidMount: ->
    @getProject()
    @getUser()

  getProject: ->
    api.type('projects').get('231')
      .then (batProject) =>
        @setState project: batProject, -> console.log 'batProject', batProject

  getUser: ->
    auth.checkCurrent()
      .then (currentUser) =>
        @setState user: currentUser, -> console.log 'currentUser', currentUser

  render: ->
    <div className="main">
      <MainHeader project={@state.user} user={@state.user} />
      <RouteHandler project={@state.project} user={@state.user} />
    </div>

routes =
  <Route name="root" path="/" handler={Main}>
    <DefaultRoute handler={require './pages/home'} />
  </Route>

Router.run routes, (Handler) ->
  React.render <Handler />, document.getElementById("app")

window.React = React
window.batsApi = api
window.batsAuth = auth