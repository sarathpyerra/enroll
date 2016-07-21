module ReportSources
  class PolicyMember
  	include Mongoid::Document
  	
    embedded_in :policy_statistic

  	field :is_tobacco_user, type: Boolean
  	field :hbx_id, type: String
  	field :dob , type: DateTime
  	field :plan_name, type: String
  	field :first_name , type: String
  	field :last_name , type: String
    field :middle_name , type: String
    field :gender , type: String
    field :is_active , type: Boolean

    embeds_many :addresses , :class_name => "ReportSources::MemberAddress" 

  end
end


    

