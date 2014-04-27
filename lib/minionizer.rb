require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/inflector'
require 'erb'
require 'net/ssh'
require 'singleton'
require 'yaml'

require 'core/task_template'
Dir[File.dirname(__FILE__) + '/**/*.rb'].each { |file| require file }
