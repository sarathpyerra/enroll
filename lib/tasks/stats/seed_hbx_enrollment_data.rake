require 'csv'

namespace :seed do
  namespace :stats do
    desc "Load the plans data"
    task :hbx_enrollment_data => :environment do

    	hbx_enrollment_and_data_mapping = {
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
      if true
        cleanup
        File.readlines("db/seedfiles/sample_data1.json").each do |line|
          line.chomp!
          line.chomp!(",")
          data = JSON.parse(line) rescue next
        # @json_data.each do |data|
        	data.deep_symbolize_keys!
          # binding.pry
          params={}
          hbx_enrollment_and_data_mapping.each do |key,value|
            params[key] = eval value rescue nil
          end
          if ReportSources::PolicyStatistic.create(params)
            puts "added one record"
          end
        end
      end
    end

    def load_data
      begin
        # puts "reading file now **************"
        # File.readlines("db/seedfiles/sample_data1.json").each do |line|
        # puts "parsing file now **************"
        # @json_data = JSON.parse(json_file)
        # puts "parsed done **************"
        # binding.pry
        return true  
      rescue Exception => e
        puts "Unable to load json file #{e}"
      end
    end

    def cleanup
      puts "Deleting all records"
      ReportSources::PolicyStatistic.destroy_all
      puts "Deleted"
    end
  end
end
