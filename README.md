# 256 interns

[![Build Status](https://api.travis-ci.org/fjordllc/interns.png?branch=master)](https://travis-ci.org/fjordllc/interns)
[![Code Climate](https://codeclimate.com/github/fjordllc/interns.png)](https://codeclimate.com/github/fjordllc/interns)
[![Coverage Status](https://coveralls.io/repos/fjordllc/interns/badge.png?branch=master)](https://coveralls.io/r/fjordllc/interns)
[![Dependency Status](https://gemnasium.com/fjordllc/interns.png)](https://gemnasium.com/fjordllc/interns)

Intern management and e-learning tool.

## Requirement

ruby-2.0.0-p

## Install

    $ bundle
    $ rake db:setup
    $ rails s

### Heroku

    $ heroku config:set LANG=ja_JP.UTF-8 INTERN_PASSWORD=xxxxxxxx
    $ heroku run rake db:migrate db:seed assets:precompile
