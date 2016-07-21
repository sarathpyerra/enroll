module ReportSources
  class MemberAddress
  	include Mongoid::Document

  	field :address_1 , type: String
    field :address_2 , type: String
    field :address_3 , type: String
    field :zip , type: String
    field :state , type: String
    field :city , type: String
    field :kind , type: String

    embedded_in :policy_member 
 
end
end