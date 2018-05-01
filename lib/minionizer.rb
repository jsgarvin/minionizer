require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/module/delegation'
require 'active_support/inflector'
require 'binding_of_caller'
require 'erb'
require 'net/scp'
require 'net/ssh'
require 'singleton'
require 'yaml'

require_relative 'core/task_template'
Dir[File.dirname(__FILE__) + '/**/*.rb'].each { |file| require file }
