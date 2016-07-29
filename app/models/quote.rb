class Quote
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidSupport::AssociationProxies
  include AASM

  extend Mongorder


  PLAN_OPTION_KINDS = [:single_plan, :single_carrier, :metal_level]
  field :quote_name, type: String, default: "Sample Quote"
  field :plan_year, type: Integer, default: TimeKeeper.date_of_record.year
  field :start_on, type: Date, default: TimeKeeper.date_of_record.beginning_of_year
  field :broker_role_id, type: BSON::ObjectId


  field :claim_code, type: String, default: ''
  associated_with_one :broker_role, :broker_role_id, "BrokerRole"


  # Quote should now support multiple benefit groups
  embeds_many :quote_benefit_groups, cascade_callbacks: true


  embeds_many :quote_households, cascade_callbacks: true


  # accepts_nested_attributes_for
  accepts_nested_attributes_for :quote_households, reject_if: :all_blank
  accepts_nested_attributes_for :quote_benefit_groups, reject_if: :all_blank

  validates_uniqueness_of :claim_code, :case_sensitive => false

  # fields for state machine
  field :aasm_state, type: String
  field :aasm_state_date, type: Date

  field :criteria_for_ui, type: String, default: []

  index({ broker_role_id: 1 })


  def self.default_search_order
    [[:quote_name, 1]]
  end

  def self.search_hash(s_rex)
    search_rex = Regexp.compile(Regexp.escape(s_rex), true)
    {
      "$or" => ([
        {"quote_name" => search_rex}
      ])
    }
  end

  def published_employee_cost
    plan && roster_employee_cost(plan.id, plan.id)
  end

  def published_employer_cost
    plan && roster_employer_contribution(plan.id, plan.id)
  end

  aasm do
    state :draft, initial: true
    state :published

    event :publish do
      transitions from: :draft, to: :published, :guard => "can_quote_be_published?"
    end
  end

  def can_quote_be_published?
    all_households_have_benefit_groups? && all_benefit_groups_have_plans?
  end

  def all_households_have_benefit_groups?
    quote_households.map(&:quote_benefit_group_id).map(&:to_s).include?(nil) ? false : true
  end

  def all_benefit_groups_have_plans?
    quote_benefit_groups.map(&:plan).include?(nil) ? false : true
  end

  def calc

    rp1 = self.quote_reference_plans.build(reference_plan_id:  "56e6c4e53ec0ba9613008f6d")
    rp1.set_bounding_cost_plans
    rp1.save
    #reference_plan=("56e6c4e53ec0ba9613008f6d")

    p = Plan.find(self.quote_reference_plans[0].reference_plan_id)

    puts "Calculating details for " + p.name

      self.quote_households.each do |hh|
        puts "   " + hh.quote_members.first.first_name
        pcd = PlanCostDecorator.new(p, hh, self, p)
        puts "Employee Cost " + pcd.total_employee_cost.to_s
        puts "Employer Contribution " + pcd.total_employer_contribution.to_s

        rp1.quote_results << pcd.get_family_details_hash
      end


      self.save
  end

  def published?
    aasm_state == "published"
  end

  def generate_character
    ascii = rand(36) + 48
    ascii += 39 if ascii >= 58
    ascii.chr.upcase
  end

  def employer_claim_code
     4.times.map{generate_character}.join + '-' + 4.times.map{generate_character}.join
  end

  def gen_data

    self.quote_name = "My Sample Quote"
    self.plan_option_kind = "single_carrier"
    self.plan_year = 2016
    self.start_on = Date.new(2016,5,2)

    build_relationship_benefits
    self.relationship_benefit_for("employee").premium_pct=(70)
    self.relationship_benefit_for("child_under_26").premium_pct=(100)

    qh = self.quote_households.build

    qm = qh.quote_members.build

    qm.first_name = "Tony"
    qm.last_name = "Schaffert"
    qm.dob = Date.new(1980,7,26)
    qm.employee_relationship = "employee"

    qm = qh.quote_members.build

    qm.first_name = "Gabriel"
    qm.last_name = "Schaffert"
    qm.dob = Date.new(2012,1,10)
    qm.employee_relationship = "child_under_26"

    qm = qh.quote_members.build

    qm.first_name = "Steve"
    qm.last_name = "Schaffert"
    qm.dob = Date.new(2012,1,10)
    qm.employee_relationship = "child_under_26"

    qm = qh.quote_members.build

    qm.first_name = "Lucas"
    qm.last_name = "Schaffert"
    qm.dob = Date.new(2012,1,10)
    qm.employee_relationship = "child_under_26"

    qm = qh.quote_members.build

    qm.first_name = "Enzo"
    qm.last_name = "Schaffert"
    qm.dob = Date.new(2012,1,10)
    qm.employee_relationship = "child_under_26"

    qm = qh.quote_members.build

    qm.first_name = "Leonardo"
    qm.last_name = "Schaffert"
    qm.dob = Date.new(1991,1,10)
    qm.employee_relationship = "child_under_26"

    self.save

    qh = self.quote_households.build
    qm = qh.quote_members.build

    qm.first_name = "Andressa"
    qm.last_name = "Schaffert"
    qm.dob = Date.new(1988,9,27)
    qm.employee_relationship = "employee"

    qm = qh.quote_members.build

    qm.first_name = "Alice"
    qm.last_name = "Schaffert"
    qm.dob = Date.new(2014,1,13)
    qm.employee_relationship = "child_under_26"
    self.save

    self.calc

  end

end
