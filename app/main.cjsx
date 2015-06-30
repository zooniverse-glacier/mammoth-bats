React = require 'react/addons'
Router = require 'react-router'
{Route, RouteHandler, DefaultRoute, Link} = require 'react-router'

Home = require './home'

Main = React.createClass
  displayName: "Main"


  render: ->
    <div className="main">
      <RouteHandler />
    </div>

routes =
  <Route name="root" path="/" handler={Main}>
    <DefaultRoute handler={Home} />
  </Route>

Router.run routes, (Handler) ->
  React.render <Handler />, document.getElementById("app")

window.React = React