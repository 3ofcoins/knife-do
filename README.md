knife-do
========

A simple knife plugin for running Rake tasks.

## Installation

Run `gem install knife-do` or add it to your Gemfile:

`gem 'knife-do'`

You can also install the plugin locally. In order to do so, copy the `lib/chef/knife/do.rb` file to the `.chef/plugins/knife/` folder in your repository.

## Usage

This plugin makes two commands available:

- `knife do`: returns the list of tasks. When invoking `knife do`, knife will ignore every flag, argument or task name passed after the command: it will always return the task list.
- `knife do task [NAME OF TASKS]`: when invoked without arguments, runs the default task.

To see all command line options available, write `knife do -h` or `knife do task -h`.

Define all tasks in a `config/tasks.rb`.
