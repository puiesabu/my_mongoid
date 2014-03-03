class Event
  include MyMongoid::Document
  field :_type, :as => :type
  field :public
  field :created_at
end
