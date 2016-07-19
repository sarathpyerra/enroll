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
    
   # MARKETS = ["individual","shop","congress","dental"]

    def self.report_lives_count_by_market

      categories = ["2014","2015","2016"]
      lives_count = {
        "individual" => lives_count_for_individual,
        "shop" => lives_count_for_shop,
        "congress" => lives_count_for_congress,
        "dental" =>lives_count_for_dental
      }
      report_data = []
      lives_count.each do |market ,report|
          report_data << {name: market ,data: report.collect{|r| r["count"]} }
      end
      [categories, report_data]
    end

    def self.lives_count_for_individual
      reports = ReportSources::PolicyStatistic.collection.aggregate([ 
        {'$match': {market: 'individual'}},
        {'$match': {plan_active_year: {"$ne" => nil}}},
        {'$group': {_id:{year: '$plan_active_year'}, count: {'$sum':1}}},
        {'$sort': {'_id.year':1}}
        ],
      :allow_disk_use => true).entries
    end

    def self.lives_count_for_shop
      reports = ReportSources::PolicyStatistic.collection.aggregate([ 
        {'$match': {market: 'employer_sponsored'}},
        {'$match': {plan_active_year: {"$ne" => nil}}},
        {'$match': {hbx_id:  {'$nin': ['536002522','526002523','536002558']}}},
        {'$group': {_id:{year: '$plan_active_year'}, count: {'$sum':1}}},
        {'$sort': {'_id.year':1}}
        ],
      :allow_disk_use => true).entries
    end

    def self.lives_count_for_dental
      reports = ReportSources::PolicyStatistic.collection.aggregate([ 
        {'$match': {plan_active_year: {"$ne" => nil}}},
        {'$match': {coverage_kind: {"$eq" => "dental"}}},
        {'$group': {_id:{year: '$plan_active_year'}, count: {'$sum':1}}},
        {'$sort': {'_id.year':1}}
        ],
      :allow_disk_use => true).entries
    end

    def self.lives_count_for_congress
      reports = ReportSources::PolicyStatistic.collection.aggregate([ 
        {'$match': {market: 'employer_sponsored'}},
        {'$match': {plan_active_year: {"$ne" => nil}}},
        {'$match': {hbx_id:  {'$in': ['536002522','526002523','536002558']}}},
        {'$group': {_id:{year: '$plan_active_year'}, count: {'$sum':1}}},
        {'$sort': {'_id.year':1}} 
        ],
      :allow_disk_use => true).entries
    end

  end 
end