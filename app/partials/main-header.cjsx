React = require 'react/addons'
ZooniverseLogo = require './zooniverse-logo'
LoginBar = require './login-bar'
AccountBar = require './account-bar'
Translate = require 'react-translate-component'
counterpart = require 'counterpart'
{Link} = require 'react-router'

module.exports = React.createClass
  displayName: 'MainHeader'

  render: ->
    <header className="main-header">
      <Link to="root"><ZooniverseLogo /></Link>
      <nav>
        <Link to="classify">Classify</Link>
      </nav>
      {if @props.user
        <AccountBar user={@props.user} auth={@props.auth} />
      else
        <LoginBar project={@props.project} auth={@props.auth} />
      }
    </header>

