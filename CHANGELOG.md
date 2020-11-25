# Change Log

## [8.2.6] - 2020-11-24

### Changed

- Backout change to Slack OAuth v2.

## [8.2.5] - 2020-11-24

### Added

- Adds backend support for the new Clubhouse integration

### Changed

- Migrate to Slack OAuth v2.

### Fixed

- Fixes an issue where buttons to sign in with GitLab and Bitbucket were missing from the web login form

## [8.2.4] - 2020-11-13

### Changed

- Backend work to make the "Work in Progress" section of the CodeStream pane more performant, with reduced api requests

## [8.2.3] - 2020-11-5

### Added

- Adds backend support for new GitHub authentication flow in VS Code
- Adds the ability to add, edit or remove ranges when editing a comment or issue

### Fixed

- Fixes an issue where the confirmation email wasn't being sent when a user changes their email address

## [8.2.2] - 2020-9-29

### Fixed

- OnPrem quickstart configuration not loading properly

## [8.2.1] - 2020-9-16

### Changed

- Adds new `notifications` scope to the GitHub Enterprise instructions to accomodate the pull-request integration
- Enforces minimum required and suggested versions of the CodeStream extension

## [8.2.0] - 2020-8-3

### Added

- Adds support for authenticating with GitLab or Bitbucket
- Adds backend support for non-admin team members to map their Git email address to their CodeStream email address

## [8.1.0] - 2020-7-21

### Added

- Adds support for self-serve payments when subscribing to CodeStream, although not yet available for on-prem

## [8.0.0] - 2020-6-30

### Added

- Adds the ability to "start work" by selecting a ticket (Trello, Jira, etc.), moving it to the appropriate in-progress state, and automatically creating a feature branch
- Adds support for creating PRs on GitHub, GitLab or Bitbucket once a code review has been approved

## [7.4.0] - 2020-6-15

### Added

- Nightly phone-home for CodeStream On-Prem
- Assign code reviews or mention people in codemarks that aren't yet on your CodeStream team
- Broadcaster health check for load balancer configurations

## [7.2.5] - 2020-5-28

### Added

- Support for On-Prem versioning
