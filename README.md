[![Code Climate](https://codeclimate.com/github/jsgarvin/minionizer.png)](https://codeclimate.com/github/jsgarvin/minionizer)
[![Build Status](https://travis-ci.org/jsgarvin/minionizer.svg?branch=master)](https://travis-ci.org/jsgarvin/minionizer)

# Minionizer

Minionizer aims to be a light weight, yet powerful, server provisioning tool with minimum learning
curve.

Minionizer is still in alpha development and is not yet ready for anything resembling production use.

# Overview

Minionizer allows you keep all of your provisioning "recipies" for a set of servers, along with any
data those recipies may need (such as config files), in a single git repository.

Minionizer uses ssh to connect to machines and run commands. There are no "agents" or other software
to install on servers before minionizer can take over.

Managed machines (minions) are assigned roles (web, db, production, staging, etc) and can be
(re)provisioned all at once by any role, or individually by server address.

Sensitive data, such as passwords, WILL BE gpg encrypted and only the encrypted copies will be checked
into the repository. If you change any of these files, Minionizer will detect the change and prompt
you to re-encrypt them and commit the newly encrypted versions.

A core set of commands WILL BE provided, such as uploading files to the server, installing apt
packages, etc. You can use these core commands to build more complex recipies, or use any of many
minionizer plugins that WILL BE available, such as posgresql installationi/upgrade, ruby
installation/upgrade, etc. 

# Installation

    gem install minionizer

# Usage

## Setup a new provisioning project in the current folder.
Note: This step doesn't actually work yet.

    minionize --init subfolder_name

Creates `subfolder_name` and initializes it with some initial folders and files to get you started.

## Modify config/minions.yml

The minions.yml file is where you define what servers this project will manage and what roles
each server will play.

You will probably want assign each server multiple roles, such as `['production', 'db']`.

## Create role instructions

A sample role file WILL BE provided in the ./roles folder to get you started. Each role file defines
what servers assigned that role should do on each (re)provisioning.

It is not necessary to create a role file for every role that you added to your config/minions.yml
file. You will likely have some roles, such as "production", that are mearly a means of grouping
several servers together and won't have a corresponding role file.  You will need at least one role,
though, such as "db" or "webserver", that will have a corresponding role file.

## Provision Servers

To provision all of the servers that are assigned a particular role, run...

    minionize role_name

This will loop through each server that is assigned `role_name` and run each role file for each role
that that server is assigned.  For instance, if a server is assigned the roles 'production' and 'db',
and you run `minionize production`, then when minionizer reaches this machine, it will run the 'db'
role file (assuming it exists in the ./roles folder).

or

    minionize my.server.address.com

This will loop through each role that is assigned to just that server, and any corresponding role
files will be run.

# Contribute

To contribute to Minionizer development you will need to install [vagrant](http://www.vagrantup.com/)
and [VirtualBox](https://www.virtualbox.org/) in order to be able to run acceptance tests.

Once installed from within your own clone of the Minionizer repo, run `rake test:vm:start` to
initialize the acceptance test virtual machine. The first time you do this it may take a long time to
download install the initial box.

To shut down the vm, run `rake test:vm:stop`.
