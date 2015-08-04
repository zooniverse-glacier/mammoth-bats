React = require 'react/addons'
Translate = require 'react-translate-component'
counterpart = require 'counterpart'
{Link} = require 'react-router'
ZooniverseLogo = require './zooniverse-logo'
Markdown = require '../components/markdown'
LoadingIndicator = require '../components/loading-indicator'

ProjectStore = require '../stores/project-store'

counterpart.registerTranslations 'en',
  footer:
    info:
      content: '''
        The Zooniverse is a collection of web-based Citizen Science projects that use the efforts of volunteers to help researchers deal with the flood of data that confronts them.
      '''
      callToAction: '''See the Zooniverse'''
    # change this to api fetch (either launch approved or featured?) when project categories exist
    projectsLists:
      space:
        header: 'Space'
        projects:
          galaxyZoo: 'Galaxy Zoo'
          milkyWayProject: 'Milky Way Project'
          solarStormWatch: 'Solar Storm Watch'
          planetHunters: 'Planet Hunters'
          planetFour: 'Planet Four'
          radioGalaxyZoo: 'Radio Galaxy Zoo'
          diskDetective: 'Disk Detective'
      climate:
        header: 'Climate'
        projects:
          oldWeather: 'Old Weather'
          cycloneCenter: 'Cyclone Center'
      nature:
        header: 'Nature'
        projects:
          snapshotSerengeti: 'Snapshot Serengeti'
          planktonPortal: 'Plankton Portal'
          floatingForests: 'Floating Forests'
          condorWatch: 'Condor Watch'
          penguinWatch: 'Penguin Watch'
          chimpAndSee: '''Chimp & See'''
          orchidObservers: 'Orchid Observers'
      humanities:
        header: 'Humanities'
        projects:
          operationWarDiary: 'Operation War Diary'
          ancientLives: 'Ancient Lives'
          notesFromNature: 'Notes from Nature'
          scienceGossip: 'Science Gossip'
      biologyAndPhysics:
        header: 'Biology and Physics'
        projects:
          cellSlider: 'Cell Slider'
          wormWatchLab: 'Worm Watch Lab'
          higgsHunters: 'Higgs Hunters'
    social:
      content: '''
        [**Zooniverse.org**](https://www.zooniverse.org/) The universe is too big to explore without you. | [Privacy Policy](https://www.zooniverse.org/privacy) | [Source & Bugs](#)
      '''
      callToAction: '''Share'''

module.exports = React.createClass
  displayName: 'MainFooter'

  getInitialState: ->
    projects: null

  componentDidMount: ->
    ProjectStore.getLaunchedProjects().then (projects) =>
      @setState projects: projects

  render: ->
    projectsLists = counterpart 'footer.projectsLists'
    <footer className="main-footer">
      <section className="main-footer-zooniverse-info">
        <ZooniverseLogo />
        <Markdown>{counterpart "footer.info.content"}</Markdown>
        <a className="footer-link-button" href="https://www.zooniverse.org/" target="_blank">
          <Translate content="footer.info.callToAction" />
        </a>
      </section>
      <section className="main-footer-projects-lists">
        {if @state.projects?
          for key, projectsList of projectsLists
            <div key={projectsList.header} className="project-list-container">
              <h5>{projectsList.header}</h5>
              <ul className="project-list">
              {for key, projectName of projectsList.projects
                <li key={key}>
                  {for project, i in @state.projects
                    <a key={i} href={if project.redirect? then project.redirect else "http://www.zooniverse.org/#/#{project.slug}"} target="_blank">
                      {projectName if projectName is project.title}
                    </a>}
                </li>}
              </ul>
            </div>
        else
          <LoadingIndicator />}
      </section>
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