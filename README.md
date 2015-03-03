# Word Diff

Word Diff empowers you to be a Markdown person in a Microsoft Word world by automatically converting any Word document committed to a GitHub repo to Markdown.

[![Build Status](https://travis-ci.org/benbalter/word_diff.svg?branch=master)](https://travis-ci.org/benbalter/word_diff)

## How it works

Lets say you have a file called `document.docx` and you commit it to your GitHub repo.

Word Diff will automatically make a second commit, along side your commit to add a `document.md` file, with the contents of `document.docx` converted to markdown. It'll even note that you're the commit author and copy over your commit message.

If you make changes and commit a new version of `document.docx`, Word Diff will update the `document.md` file, and if you delete `document.docx`, `document.md` gets deleted as well.

Under the hood, it uses [word-to-markdown](https://github.com/benbalter/word-to-markdown).

## When you'd use this

If you're collaborating on text with someone:

1. Using Git's native diff functionality, you can quickly verified what's changed or compare changes over time
2. You can collaborate in Markdown/GitHub while the world collaborates via email/Word

## Setup

1. Create a bot account, and [create a new personal access token](https://github.com/settings/tokens/new) with `public_repo` scope
2. Set the token as a `GITHUB_TOKEN` environmental variable.
3. Add the Word Diff server as a web hook on the repository, receiving push events. You can leave all other settings about formats as they are. Choose a shared secret token as `SECRET_TOKEN` which you then have to set on your server/hosting as well. See how you set it on heroku below.
4. for local use, you can also store those variables in .env which you then should add to your .gitignore

## Running on Heroku

1. If you are familiar with heroku, just do what you do. If not, follow the ruby guide for heroku until you are logged in https://devcenter.heroku.com/articles/getting-started-with-ruby
2. Clone the worddiff repo to a local folder of your choosing. Create the .env file with the above mentioned `GITHUB_TOKEN` and `SECRET_TOKEN`.
3. With heroku installed, do `heroku create` in the worddiff folder. This also adds a heroku remote to your local git repo.
4. In order to get LibreOffice installed, you'll want to run `heroku config:add BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git`. This will instruct Heroku to read the `.buildpacks` file. Ideally do this before you push to heroku the first time.
5. Then set the two environment variable for Heroku: `heroku config:set GITHUB_TOKEN=yourTokenHere` and `heroku config:set SECRET_TOKEN=yoursecretchosentoken`
6. Finally do `git push heroku master` and the app should be deployed. The heroku repo should have been added before.
7. When opening the website heroku tells you, there should be nothing there but no error either.

## Troubleshooting

1. Check logs.
2. Check if webhook works at the repository.

## Running locally

1. `bundle exec rackup`
2. Follow the [ngrok documentation](https://developer.github.com/webhooks/configuring/#using-ngrok) to forward requests to your computer if you don't want to set up a development server
