React = require 'react/addons'
ZooniverseLogo = require './zooniverse-logo'
LoginBar = require './login-bar'
AccountBar = require './account-bar'
Translate = require 'react-translate-component'
counterpart = require 'counterpart'
{Link} = require 'react-router'

counterpart.registerTranslations 'en',
  mainHeader:
    title: 'Night Flights'

module.exports = React.createClass
  displayName: 'MainHeader'

  render: ->
    <header className="main-header">
      <Link className="main-header-title-link" to="root"><Translate content="mainHeader.title" /></Link>
      <nav className="main-header-nav">
        <Link to="classify" className="main-header-link">Classify</Link>
        <Link to="about" className="main-header-link">About</Link>
      </nav>
      {if @props.user
        <AccountBar user={@props.user} />
      else
        <LoginBar project={@props.project} />
      }
    </header>
