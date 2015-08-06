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

  componentDidMount: ->
    if window.innerWidth <= 768
      window.onhashchange = @onHashChange

  onHashChange: ->
    mainHeaderNav = React.findDOMNode(@refs.mainHeaderNav)

    if mainHeaderNav.classList.contains 'show-menu'
      @toggleMenu()

  toggleMenu: ->
    mainHeaderNav = React.findDOMNode(@refs.mainHeaderNav)

    mainHeaderNav.classList.toggle 'show-menu'
    return # to get rid of the annoying react warning

  render: ->
    <header className="main-header">
      <div className="main-header-title-container">
        <Link className="main-header-title-link" to="root"><Translate content="mainHeader.title" /></Link>
      </div>
      <nav ref="mainHeaderNav" className="main-header-nav">
        <div className="main-header-nav-link-container">
          <Link to="classify" className="main-header-link"><Translate content="mainHeader.links.classify" /></Link>
          <Link to="about" className="main-header-link"><Translate content="mainHeader.links.about" /></Link>
          <a className="main-header-link" href="#" target="_blank"><Translate content="mainHeader.links.discuss" /></a>
          <a className="main-header-link" href="#" target="_blank"><Translate content="mainHeader.links.blog" /></a>
        </div>
        {if @props.user
          <AccountBar user={@props.user} />
        else
          <LoginBar project={@props.project} />}
      </nav>


      <button className="mobile-menu-button" type="button" onClick={@toggleMenu}>
        <img className="menu-icon" src="./assets/mobile-menu.svg" alt="menu" />
      </button>
    </header>
