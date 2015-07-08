React = require 'react/addons'
Router = require 'react-router'
{Route, RouteHandler, DefaultRoute, Link} = require 'react-router'
Reflux = require 'reflux'
BatsClient = require './api/bats-client'
{api} = require './api/bats-client'
{auth} = require './api/bats-client'
PromiseToSetState = require './lib/promise-to-set-state'

MainHeader = require './partials/main-header'

Main = React.createClass
  displayName: "Main"
  mixins: [PromiseToSetState]

  getInitialState: ->
    project: null
    user: null

  componentDidMount: ->
    @getProject()
    @handleAuthChange()
    auth.listen @handleAuthChange


  getProject: ->
    api.type('projects').get('865')
      .then (batProject) =>
        @setState project: batProject, ->
          console.log 'batProject', batProject
          window.batsProject = @state.project

  componentWillUnmount: ->
    auth.stopListening @handleAuthChange

  handleAuthChange: ->
    @promiseToSetState user: auth.checkCurrent()

  render: ->
    <div className="main">
      <MainHeader project={@state.project} user={@state.user} auth={auth} api={api} />
      <RouteHandler project={@state.project} user={@state.user} auth={auth} api={api} />
    </div>

routes =
  <Route name="root" path="/" handler={Main}>
    <DefaultRoute handler={require './pages/home'} />

    <Route name="classify" path="classify" handler={require './pages/classify'} />
  </Route>

Router.run routes, (Handler) ->
  React.render <Handler />, document.getElementById("app")

window.React = React
window.batsApi = api
window.batsAuth = auth