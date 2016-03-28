module Importers
  class ConversionEmployer
    include ActiveModel::Validations
    include ActiveModel::Model

    attr_reader :fein, :broker_npn

    attr_accessor :action,
      :dba,
      :legal_name,
      :primary_location_address_1,
      :primary_location_address_2,
      :primary_location_city,
      :primary_location_state,
      :primary_location_zip,
      :mailing_location_address_1,
      :mailing_location_address_2,
      :mailing_location_city,
      :mailing_location_state,
      :mailing_location_zip,
      :contact_email,
      :contact_phone,
      :enrolled_employee_count,
      :new_hire_count,
      :broker_name

    validates_presence_of :legal_name, :allow_blank => false
    validates_length_of :fein, is: 9

    validate :validate_new_fein
    validate :broker_exists_if_specified

    attr_reader :warnings

    def initialize(opts = {})
      super(opts)
      @warnings = ActiveModel::Errors.new(self)
    end

    def fein=(val)
      @fein = Maybe.new(val).strip.gsub(/\D/, "").extract_value
    end

    def broker_npn=(val)
      @broker_npn = Maybe.new(val).strip.extract_value
    end

    def validate_new_fein
      return true if fein.blank?
      if Organization.where(:fein => fein).any?
        errors.add(:fein, "is already taken")
      end
    end

    def broker_exists_if_specified
      return true if broker_npn.blank?
      unless BrokerRole.by_npn(broker_npn).any?
        warnings.add(:broker_npn, "does not correspond to an existing Broker")
      end
    end

    def map_office_locations
      locations = []
      main_address = Address.new(
        :kind => "work",
        :address_1 => primary_location_address_1,
        :address_2 => primary_location_address_2,
        :city =>  primary_location_city,
        :state => primary_location_state,
        :zip => primary_location_zip
      )
      mailing_address = Address.new(
        :kind => "work",
        :address_1 => mailing_location_address_1,
        :address_2 => mailing_location_address_2,
        :city =>  mailing_location_city,
        :state => mailing_location_state,
        :zip => mailing_location_zip
      )
      main_location = OfficeLocation.new({
        :address => main_address,
        :phone => Phone.new({
          :kind => "work",
          :full_phone_number => contact_phone
        }),
        :is_primary => true 
      })
      locations << main_location
      if !mailing_address.blank?
        if !mailing_address.matches?(main_address)
          locations << OfficeLocation.new({
            :is_primary => false,
            :address => mailing_address
          })
        end
      end
      locations
    end

    def assign_brokers
      broker_agency_accounts = []
      if !broker_npn.blank?
        br = BrokerRole.by_npn(broker_npn).first
        if !br.nil?
          broker_agency_accounts << BrokerAgencyAccount.new({
            start_on: Time.mktime(2016,4,1,0,0,0),
            writing_agent_id: br.id,
            broker_agency_profile_id: br.broker_agency_profile_id
          })
        end
      end 
      broker_agency_accounts
    end

    def save
      return false unless valid?
      new_organization = Organization.new({
        :fein => fein,
        :legal_name => legal_name,
        :dba => dba,
        :office_locations => map_office_locations,
        :employer_profile => EmployerProfile.new({
          :broker_agency_accounts => assign_brokers,
          :entity_kind => "c_corporation"
        })
      })
      save_result = new_organization.save
      propagate_errors(new_organization)
      return save_result
    end

    def propagate_errors(org)
      org.errors.each do |attr, err|
        errors.add(attr, err)
      end
      org.office_locations.each_with_index do |office_location, idx|
        office_location.errors.each do |attr, err|
          errors.add("office_location_#{idx}_" + attr.to_s, err)
        end
      end
    end
  end
end