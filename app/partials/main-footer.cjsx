React = require 'react/addons'
Translate = require 'react-translate-component'
counterpart = require 'counterpart'
{Link} = require 'react-router'
ZooniverseLogo = require './zooniverse-logo'
Markdown = require '../components/markdown'

counterpart.registerTranslations 'en',
  footer:
    content: '''
      The Zooniverse is a collection of web-based Citizen Science projects that use the efforts of volunteers to help researchers deal with the flood of data that confronts them.
    '''

module.exports = React.createClass
  displayName: 'MainFooter'

  render: ->
    <footer className="main-footer">
      <ZooniverseLogo />
      <Markdown>{counterpart "footer.content"}</Markdown>
    </footer>