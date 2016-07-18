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
    field :policy_purchased_on, type: DateTime
    field :members_count, type: Integer


    def self.lives_count_by_market(market="individual")
      collection.aggregate([ 
        {'$match': {market: 'individual'}},
        {'$match': {plan_active_year: {"$ne" => nil}}},
        {'$group': {_id:{year: '$plan_active_year'}, count: {'$sum':1}}} 
        ]).entries
    end
  end
end