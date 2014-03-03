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

  # Get the default database session
  #
  # @example
  #   MyMongoid.default_session
  #
  # @return [ Moped::Session ] The default session
  def self.default_session
    @session ||= create_session()
    @session
  end

  # Create new database session
  #
  # @example
  #   MyMongoid.create_session
  #
  # @return [ Moped::Session ] new Moped session
  def self.create_session
    session = Moped::Session.new(["localhost:27017"])
    session.use("my_mongoid")
    session
  end
end
