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

    embeds_many :policy_members , :class_name => "ReportSources::PolicyMember" 


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

    def self.report_lives_count_by_gender

      categories = ["INDIVIDUAL","SHOP","CONGRESS","DENTAL"]
      lives_count = {
        "individual" => lives_count_for_individual_by_gender,
        "shop" => lives_count_for_shop_by_gender,
        "congress" => lives_count_for_congress_by_gender,
        "dental" => lives_count_for_dental_by_gender
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

    def self.lives_count_for_individual_by_gender
      reports = ReportSources::PolicyStatistic.collection.aggregate([ 
        {'$project': { gender: "$policy_members.gender" , market: "$market", plan_active_year: "$plan_active_year" } },
        {'$match': {market: 'individual'}},
        {'$unwind': "$gender"},
        {'$match': {plan_active_year: {"$ne" => nil}}},
        {'$group': {_id:{gender: '$gender'}, count: {'$sum':1}}},
        ],
      :allow_disk_use => true).entries
    end

    def self.lives_count_for_shop_by_gender
      reports = ReportSources::PolicyStatistic.collection.aggregate([ 
        {'$project': { gender: "$policy_members.gender" , market: "$market", plan_active_year: "$plan_active_year" } },
        {'$match': {market: 'employer_sponsored'}},
        {'$unwind': "$gender"},
        {'$match': {plan_active_year: {"$ne" => nil}}},
        {'$group': {_id:{gender: '$gender'}, count: {'$sum':1}}},
        ],
      :allow_disk_use => true).entries
    end

    def self.lives_count_for_congress_by_gender
      report = ReportSources::PolicyStatistic.collection.aggregate([ 
        {'$project': { gender: "$policy_members.gender" , market: "$market", 
                       plan_active_year: "$plan_active_year", hbx_id: "$hbx_id" }},
        {'$match': {market: 'employer_sponsored'}},
        {'$match': {hbx_id:  {'$in': ['536002522','526002523','536002558']}}},
        {'$unwind': "$gender"},
        {'$match': {plan_active_year: {"$ne" => nil}}},
        {'$group': {_id:{gender: '$gender'}, count: {'$sum':1}}},
        ],
      :allow_disk_use => true).entries
      # work around for blank data
      [{"_id"=>{"gender"=>"female"}, "count"=>0}, {"_id"=>{"gender"=>"male"}, "count"=>0}] if report.empty?
    end

    def self.lives_count_for_dental_by_gender
      reports = ReportSources::PolicyStatistic.collection.aggregate([ 
        {'$project': { gender: "$policy_members.gender" , market: "$market", plan_active_year: "$plan_active_year", coverage_kind: "$coverage_kind" } },
        {'$match': {coverage_kind: {"$eq" => "dental"}}},
        {'$unwind': "$gender"},
        {'$match': {plan_active_year: {"$ne" => nil}}},
        {'$group': {_id:{gender: '$gender'}, count: {'$sum':1}}},
        ],
      :allow_disk_use => true).entries
    end


    def self.lives_count_for_individual_by_zip
      reports = ReportSources::PolicyStatistic.collection.aggregate([ 
        {'$project': { zip: "$policy_members.addresses.zip" , market: "$market", plan_active_year: "$plan_active_year" } },
        {'$match': {market: 'individual'}},
        {'$unwind': "$zip"},
        {'$unwind': "$zip"},
        {'$match': {plan_active_year: {"$ne" => nil}}},
        {'$group': {_id:{zip: '$zip'}, count: {'$sum':1}}},
        ],
      :allow_disk_use => true).entries
    end

  end 
end