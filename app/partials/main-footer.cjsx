React = require 'react/addons'
Translate = require 'react-translate-component'
counterpart = require 'counterpart'
{Link} = require 'react-router'
ZooniverseLogo = require './zooniverse-logo'
Markdown = require '../components/markdown'

counterpart.registerTranslations 'en',
  footer:
    info:
      content: '''
        The Zooniverse is a collection of web-based Citizen Science projects that use the efforts of volunteers to help researchers deal with the flood of data that confronts them.
      '''
    social:
      content: '''
        [**Zooniverse.org**](https://www.zooniverse.org/) The universe is too big to explore without you.
      '''
      callToAction: '''Share'''

module.exports = React.createClass
  displayName: 'MainFooter'

  render: ->
    <footer className="main-footer">
      <section className="main-footer-zooniverse-info">
        <ZooniverseLogo />
        <Markdown>{counterpart "footer.info.content"}</Markdown>
      </section>
      <section className="main-footer-projects-list"></section>
      <section className="main-footer-social-media">
        <Markdown>{counterpart "footer.social.content"}</Markdown>
        <div className="social-media-links">
          <Translate component="span" content="footer.social.callToAction" />
          <a href="#"><i className="fa fa-twitter fa-2x"></i></a>
          <a href="#"><i className="fa fa-facebook-official fa-2x"></i></a>
          <a href="#"><i className="fa fa-google-plus-square fa-2x"></i></a>
        </div>
      </section>
    </footer>