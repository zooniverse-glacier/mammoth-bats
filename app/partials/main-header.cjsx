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
    links:
      about: 'About'
      classify: 'Classify'
      discuss: 'Discuss'
      blog: 'Blog'

module.exports = React.createClass
  displayName: 'MainHeader'

  render: ->
    <header className="main-header">
      <Link className="main-header-title-link" to="root"><Translate content="mainHeader.title" /></Link>
      <nav className="main-header-nav">
        <Link to="classify" className="main-header-link"><Translate content="mainHeader.links.classify" /></Link>
        <Link to="about" className="main-header-link"><Translate content="mainHeader.links.about" /></Link>
        <a className="main-header-link" href="#" target="_blank"><Translate content="mainHeader.links.discuss" /></a>
        <a className="main-header-link" href="#" target="_blank"><Translate content="mainHeader.links.blog" /></a>
      </nav>
      {if @props.user
        <AccountBar user={@props.user} />
      else
        <LoginBar project={@props.project} />
      }
      {<img className="menu-icon" src="./assets/mobile-menu.svg" alt="menu" /> if window.innerWidth <= 320}
      {<span className="mobile-menu-title">Menu</span> if window.innerWidth <= 320}
    </header>
