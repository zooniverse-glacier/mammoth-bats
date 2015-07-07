React = require 'react'
ChangeListener = require '../components/change-listener'
{Link} = require 'react-router'
# auth = require '../api/auth'
# talkClient = require '../api/talk'
counterpart = require 'counterpart'
Translate = require 'react-translate-component'
# Avatar = require '../partials/avatar'

counterpart.registerTranslations 'en',
  accountMenu:
    profile: 'Profile'
    settings: 'Settings'
    signOut: 'Sign Out'
    collections: 'Collections'

module.exports = React.createClass
  displayName: 'AccountBar'

  getInitialState: ->
    unread: false

  # componentDidMount: ->
  #   window.addEventListener 'hashchange', @setUnread
  #   @setUnread()

  # componentWillUnmount: ->
  #   window.removeEventListener 'hashchange', @setUnread

  # setUnread: ->
  #   talkClient.type('conversations').get({user_id: @props.user.id, unread: true, page_size: 1})
  #     .then (conversations) =>
  #       @setState {unread: !!conversations.length}
  #     .catch (e) -> console.log "e unread messages", e

  handleSignOutClick: ->
    @props.auth.signOut()

  render: ->
    <ChangeListener target={@props.user} handler={=>
      <div className="account-bar">
        <div className="account-info">
          <span className="display-name"><strong>{@props.user.display_name}</strong></span>
        </div>
        <button type="button" onClick=@handleSignOutClick>
          <Translate content="accountMenu.signOut" />
        </button>
      </div>
    } />

