require 'active_support/inflector'
require 'singleton'
require 'yaml'
Dir[File.dirname(__FILE__) + '/minionizer/*.rb'].each { |file| require file }
