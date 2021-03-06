require "moped"

require "my_mongoid/configuration"
require "my_mongoid/version"
require "my_mongoid/document"

module MyMongoid
  
  # Get all the models in the application - this is everything that includes
  # MyMongoid::Document.
  #
  # @example Get all the models.
  #   MyMongoid.models
  #
  # @return [ Array<Class> ] All the models in the application.
  def self.models
    @models ||= []
  end

  # Register a model in the application with MyMongoid.
  #
  # @example Register a model.
  #   MyMongoid.register_model(Band)
  #
  # @param [ Class ] klass The model to register.
  def self.register_model(klass)
    @models ||= []
    @models.push(klass) unless @models.include?(klass)
  end

  def self.configuration
    MyMongoid::Configuration.instance
  end

  def self.configure
    block_given? ? yield(self.configuration) : self.configuration
  end

  def self.session
    raise UnconfiguredDatabaseError unless configuration.host
    raise UnconfiguredDatabaseError unless configuration.database
    @session ||= create_session
  end

  def self.create_session
    session ||= ::Moped::Session.new([configuration.host])
    session.use configuration.database
    session
  end

  def self.purge!
    session.collections.each do |collection|
      collection.drop
    end and true
  end
end
