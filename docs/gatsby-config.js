
const  { navConfig, footerNavConfig, codeStreamCfg } = require('./codestream-config');
const thisDocModule = 'On-Prem Guide'

navConfig[thisDocModule].omitLandingPage = true;
module.exports = {
	pathPrefix: '/onprem',
	plugins: [
		{
			resolve: 'gatsby-theme-apollo-docs',
			options: {
				codeStreamDocModule: thisDocModule,  // this is definitely NOT ideal - see docset-menu.js
				siteName: 'CodeStream On-Prem Guide',
				pageTitle: 'My Page Title', // ?
				menuTitle: codeStreamCfg.ecoSystem,
				segmentApiKey: codeStreamCfg.segmentApiKey,
				baseUrl: codeStreamCfg.baseUrl,
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
				sidebarCategories: {
					null: ['index'],
					Configurations: [
						'configs/service-overview',
						'configs/single-host-linux',
					],
					Email: [
						'email/outbound'
					],
					'Messaging Integrations': [
						'messaging/network',
						'messaging/slack',
						'messaging/msteams',
					],
					'Issue Ingtegrations': [
						'issues/overview',
					],
					'IDE Settings': [
						'ide/overview',
					],
					// FAQ: [
					// 	'faq/proxy',
					// ],
				},
				navConfig,
				footerNavConfig,
			},
		},
	],
}
