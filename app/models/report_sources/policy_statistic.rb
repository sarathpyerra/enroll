module ReportSources
  class PolicyStatistic
  	include Mongoid::Document
  	field :plan_active_year, type: String
  	field :hbx_id, type: String
  	field :plan_legal_name, type: String
  	field :plan_name, type: String
  	field :plan_type, type: String
  	field :coverage_kind, type: String
    field :plan_id, type: BSON::ObjectId
    field :enrollment_kind, type: String
    field :metal_level, type: String
    field :aasm_state, type: String
    field :market_coverage, type: String
    field :market, type: String
    field :is_standard_plan, type: Boolean, default: false
    field :carrier_profile_id, type: BSON::ObjectId
    field :policy_purchased_at, type: DateTime
  end
end