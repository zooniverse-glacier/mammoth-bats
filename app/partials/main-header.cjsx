React = require 'react/addons'
ZooniverseLogo = require './zooniverse-logo'
LoginBar = require './login-bar'
AccountBar = require './account-bar'
Translate = require 'react-translate-component'
counterpart = require 'counterpart'

module.exports = React.createClass
  displayName: 'MainHeader'

  render: ->
    <header className="main-header">
      <ZooniverseLogo />
      <nav></nav>
      {if @props.user
        <AccountBar user={@props.user} auth={@props.auth} />
      else
        <LoginBar project={@props.project} auth={@props.auth} />
      }
    </header>

