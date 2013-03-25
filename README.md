# 256 interns

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
