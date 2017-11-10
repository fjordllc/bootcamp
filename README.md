# 256 interns

[![CircleCI](https://circleci.com/gh/fjordllc/interns.svg?style=svg&circle-token=dcbfd5d67e9be5401ce486b74f585879bc58a692)](https://circleci.com/gh/fjordllc/interns)

Intern management and e-learning tool.

## Install

    $ brew install yarn
    $ bin/setup
    $ yarn install
    $ rails s

You can also launch a web server with [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler).

    $ RACK_PROFILER=1 rails s

### Heroku

    $ heroku config:set LANG=ja_JP.UTF-8 INTERN_PASSWORD=xxxxxxxx
    $ heroku run rails db:setup
