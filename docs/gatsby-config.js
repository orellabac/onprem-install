
const  { navConfig, footerNavConfig, codeStreamCfg } = require('./codestream-config');
const thisDocModule = 'On-Prem Administration';

navConfig[thisDocModule].omitLandingPage = true;
module.exports = {
	pathPrefix: '/onprem',
	plugins: [
		{
			resolve: 'gatsby-theme-apollo-docs',
			options: {
				// THIS SECTION SHOULD BE THE SAME ACROSS ALL CODESTREAM DOC SITES
				codeStreamDocModule: thisDocModule,  // this is definitely NOT ideal - see docset-menu.js
				siteName: thisDocModule,
				// pageTitle: thisDocModule, // for social cards, ...
				menuTitle: codeStreamCfg.ecoSystem,
				segmentApiKey: codeStreamCfg.segmentApiKey,
				// baseUrl: codeStreamCfg.baseUrl,
				twitterHandle: codeStreamCfg.twitter,
				youtubeUrl: codeStreamCfg.youTubeUrl,
				logoLink: codeStreamCfg.marketingSite,
				baseDir: 'docs',
				contentDir: 'src',
				root: __dirname,
				subtitle: thisDocModule,
				description: navConfig[thisDocModule].description,
				// githubRepo: 'teamcodestream/codestream-guide',  // exposes a github repo link on right rail
				// spectrumPath: '/',
				navConfig,
				footerNavConfig,

				// Navigation - the order of these properties seems to be used on the site ??
				sidebarCategories: {
					null: ['index', 'tos'],
					'Installation Types': [
						'configs/service-overview',
						'configs/single-host-linux',
					],
					'Service Configurations': [
						'serviceconfigs/ssl',
						'serviceconfigs/outbound',
						'serviceconfigs/telemetry',
						'serviceconfigs/awsAlb'
					],
					'Messaging Integrations': [
						'messaging/network',
						'messaging/slack',
						'messaging/msteams',
					],
					'Issue Integrations': [
						'issues/overview',
						'issues/asana',
						'issues/azuredevops',
						'issues/bitbucket',
						'issues/github',
						'issues/gitlab',
						'issues/jira',
						'issues/trello',
					],
					'Other Integrations': [
						'otherintegrations/okta'
					],
					'IDE Settings': [
						'ide/overview',
					],
					FAQ: [
						'faq/passwords',
					],
				},
			},
		},
	],
}
