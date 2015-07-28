React = require 'react'
classnames = require 'classnames'

Reflux = require 'reflux'
favoritesStore = require '../stores/favorites-store'

module.exports = React.createClass
  displayName: 'FavoritesButton'
  mixins: [Reflux.connect(favoritesStore, 'favorites')]

  getInitialState: ->
    favorited: false

  onClick: ->
    @setState favorited: !@state.favorited

  render: ->
    favoriteBtnClasses = classnames
      'favorite-button': true
      favorited: @state.favorited is true

    <button className={favoriteBtnClasses} type="button" onClick={@onClick}>
      <i className="fa fa-heart#{unless @state.favorited then '-o' else ''} fa-2x"></i>
    </button>