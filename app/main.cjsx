React = require 'react/addons'
Router = require 'react-router'
{Route, RouteHandler, DefaultRoute, Link} = require 'react-router'
Reflux = require 'reflux'
projectConfig = require './lib/project-config'
{api} = client = require './api/bats-client'
userStore = require './stores/user-store'

MainHeader = require './partials/main-header'
MainFooter = require './partials/main-footer'

Main = React.createClass
  displayName: "Main"
  mixins: [Reflux.connect(userStore, 'user')]

  render: ->
    <div className="main">
      <MainHeader user={@state.user} />
      <RouteHandler user={@state.user} />
      <MainFooter />
    </div>

routes =
  <Route name="root" path="/" handler={Main}>
    <DefaultRoute handler={require './pages/home'} />

    <Route name="classify" path="classify" handler={require './pages/classify/classify'} />
    <Route name="about" path="about" handler={require './pages/about'} />
  </Route>

Router.run routes, (Handler) ->
  React.render <Handler />, document.getElementById("app")

window.React = React
window.batsApi = api
