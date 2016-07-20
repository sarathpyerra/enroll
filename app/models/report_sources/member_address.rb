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

    belongs_to :policy_member
 
# NOT USING AT THE MOMENT .......SY/JUL 20
# def self.report_lives_count_by_zip

#       categories = ["2014","2015","2016"]
#       zip_count = {
#         "individual" => report_lives_count_by_zip,
#       }
#       report_data = []
#       zip_count.each do |market ,report|
#           report_data << {name: market ,data: report.collect{|r| r["count"]} }
#       end
#       [categories, report_data]
#     end

#     def self.zipcode_for_individual
#       reports = ReportSources::MemberAddress.collection.aggregate([ 
#         #{'$match': {market: 'individual'}},
#         #{'$match': {plan_active_year: {"$ne" => nil}}},
#         {'$match': {zip: {"$ne" => nil}}},
#         {'$group': {_id:{year: '$plan_active_year'}, count: {'$sum':1}}},
#         {'$sort': {'_id.year':1}}
#         ],
#       :allow_disk_use => true).entries
#     end
 end
end