module MyMongoid

  # This error is raised when field is declared twice
  class DuplicateFieldError < RuntimeError
  end

  # This error is raised when field is undeclared
  class UnknownAttributeError < RuntimeError
  end

  # This error is raised when host and database are not configured
  class UnconfiguredDatabaseError < ArgumentError
  end
end
