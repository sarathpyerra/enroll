module ReportSources
  class PolicyMemberStatistic
  	include Mongoid::Document
  	embedded_in :policy_statistic

  	field :is_tobacco_user, type: Boolean
  	field :hbx_id, type: String
  	field :dob , type: DateTime
  	field :plan_name, type: String
  	field :first_name , type: String
  	field :last_name , type: String
  end
end
