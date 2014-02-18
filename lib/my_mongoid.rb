require "my_mongoid/version"
require "my_mongoid/document"

module MyMongoid
  # Your code goes here...
  
  # Get all the models in the application - this is everything that includes
  # MyMongoid::Document.
  #
  # @example Get all the models.
  #   MyMongoid.models
  #
  # @return [ Array<Class> ] All the models in the application.
  #
  # @since 0.0.1
  def self.models
    @models ||= []
  end

  # Register a model in the application with MyMongoid.
  #
  # @example Register a model.
  #   MyMongoid.register_model(Band)
  #
  # @param [ Class ] klass The model to register.
  #
  # @since 0.0.1
  def self.register_model(klass)
    @models ||= []
  	@models.push(klass) unless @models.include?(klass)
  end
end
