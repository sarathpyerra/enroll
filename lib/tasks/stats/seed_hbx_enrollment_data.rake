require 'csv'

namespace :seed do
  namespace :stats do
    desc "Load the plans data"
    task :hbx_enrollment_data => :environment do

    	hbx_enrollment_data_mapping = {
    		:plan_active_year => "data[:plan][:active_year]",
    		:hbx_id => "data[:hbx_id]",    		
    		:plan_name => "data[:plan][:name]",
    		:plan_type =>	"data[:plan][:plan_type]",
    		:coverage_kind => "data[:coverage_kind]",
    		:plan_id => "data[:plan_id][:$oid]",
    		:enrollment_kind => "data[:enrollment_kind]",
    		:metal_level => "data[:plan][:metal_level]",
    		:aasm_state => "data[:aasm_state]",
    		:market  => "data[:kind]",
    		:is_standard_plan => "data[:is_standard_plan]",
    		:policy_purchased_on => "data[:plan][:created_at][:$date]",
        :members_count => "data[:hbx_enrollment_members].count"
    	}
      person_data_mapping  = {
        :is_tobacco_user => "person_data[:is_tobacco_user]",
        :first_name => "person_data[:first_name]",
        :last_name => "person_data[:last_name]",
        :middle_name => "person_data[:middle_name]",
        :gender =>"person_data[:gender]",
        :dob => "person_data[:dob][:$date]",
        :is_active => "person_data[:is_active]",
        :hbx_id => "person_data[:hbx_id]"
      }

      address_data_mapping = {
        :address_1 => "address_data[:address_1]",
        :address_2 => "address_data[:address_2]",
        :address_3 => "address_data[:address_3]",
        :zip => "address_data[:zip]",
        :state => "address_data[:state]",
        :city => "address_data[:city]",
        :kind => "address_data[:kind]"
      }

      cleanup
      File.readlines("db/seedfiles/sample_data1.json").each do |line|
        line.chomp!
        line.chomp!(",")
        data = JSON.parse(line) rescue next
      	data.deep_symbolize_keys!
        params={}
        hbx_enrollment_data_mapping.each do |key,value|
          params[key] = eval value rescue nil
        end
        policy = ReportSources::PolicyStatistic.create(params)
        puts "policy created #{policy.id}"
        # Check of memeners present
        if data[:hbx_enrollment_members].present?
          data[:hbx_enrollment_members].each do |enrollment| 
            person_data = enrollment[:person]
            memeber_params = {}
            person_data_mapping.each do |key,value|
              memeber_params[key] = eval value rescue nil
            end
            # policy_member= ReportSources::PolicyMember.create(memeber_params)
            policy_member = policy.policy_members.create(memeber_params) #<< policy_member
            puts "Member added for policy #{policy.id}"
            # Check if address present
            if person_data && person_data[:addresses].present?
              person_data[:addresses].each do |address_data| 
                address_params = {}
                address_data_mapping.each do |key,value|
                  address_params[key] = eval value rescue nil
                end
                # member_address= ReportSources::MemberAddress.create(address_params)
                policy_member.addresses.create(address_params)
                puts "address added for policy #{policy.id}"
              end
            end
          end
        end
      end
    end

    def cleanup
      puts "Deleting all records"
      ReportSources::PolicyStatistic.destroy_all
      puts "Deleted"
    end
  end
end
