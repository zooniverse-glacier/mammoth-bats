React = require 'react/addons'
Router = require 'react-router'
{Route, RouteHandler, DefaultRoute, Link} = require 'react-router'
Reflux = require 'reflux'
{api} = client = require './api/bats-client'
userStore = require './stores/user-store'

MainHeader = require './partials/main-header'
MainFooter = require './partials/main-footer'

Main = React.createClass
  displayName: "Main"
  mixins: [Reflux.connect(userStore, 'user')]

  getInitialState: ->
    project: null

  getProject: ->
    api.type('projects').get('865')
      .then (project) =>
        @setState { project }

  render: ->
    console.log @state.user
    <div className="main">
      <MainHeader project={@state.project} user={@state.user} />
      <RouteHandler project={@state.project} user={@state.user} />
      <MainFooter />
    </div>

routes =
  <Route name="root" path="/" handler={Main}>
    <DefaultRoute handler={require './pages/home'} />

    <Route name="classify" path="classify" handler={require './pages/classify/classify'} />
  </Route>

Router.run routes, (Handler) ->
  React.render <Handler />, document.getElementById("app")

window.React = React
window.batsApi = api
