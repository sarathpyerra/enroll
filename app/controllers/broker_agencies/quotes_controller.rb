class BrokerAgencies::QuotesController < ApplicationController

  include DataTablesAdapter

  before_action :find_quote , :only => [:destroy ,:show, :delete_member, :delete_household, :publish_quote, :view_published_quote]
  before_action :format_date_params  , :only => [:update,:create]
  before_action :employee_relationship_map
  before_action :set_qhp_variables, :only => [:plan_comparison, :download_pdf]

  def view_published_quote

  end

  def publish_quote

    # TODO VARUN => Add more checks to publish and save

    if @quote.may_publish?
      @benefit_group = @quote.quote_benefit_groups.first
      @benefit_group.plan_option_kind = params[:plan_option_kind].gsub(' ','_').downcase
      @benefit_group.published_reference_plan = Plan.find(params[:reference_plan_id]).id
      @quote.publish!
      @quote.save!
    end

    render "publish_quote" , :flash => {:notice => "Quote Published" }

  end

  # displays index page of quotes
  def my_quotes
    @all_quotes = Quote.where("broker_role_id" => current_user.person.broker_role.id)
  end

  def quote_index_datatable

    dt_query = extract_datatable_parameters

    quotes = Quote.where("broker_role_id" => current_user.person.broker_role.id)

    @total_records = quotes.count
    @records_filtered = quotes.count

    unless dt_query.search_string.blank?
      quotes = quotes.search(dt_query.search_string)
      @records_filtered = quotes.count
    end

    quotes = quotes.skip(dt_query.skip).limit(dt_query.take)

    @payload = quotes.map { |q|
      {
        :quote_name => (view_context.link_to q.quote_name, broker_agencies_quote_path(q.id)),
        :family_count => q.quote_households.count,
        :benefit_group_count => q.quote_benefit_groups.count,
        :claim_code => q.claim_code,
        :quote_state => q.aasm_state,
        :quote_roster => (view_context.link_to "View/Edit", edit_broker_agencies_quote_path(q.id)),
        :quote_download => quote_download_link(q),
        :quote_delete => ('<button type="button" onclick="delete_quote_handler" id="close_button" data-quote-id="' + q.id + '" class="close" aria-label="Close"><span aria-hidden="true">&times;</span></button>').html_safe

      }
    }

      @draw = dt_query.draw

  end

  def show #index (old index)
    @q = Quote.find(params[:id])
    @benefit_groups = @q.quote_benefit_groups
    @quote_on_page = (params[:benefit_group_id] && @q.quote_benefit_groups.find(params[:benefit_group_id])) || @benefit_groups.first

    active_year = Date.today.year
    @coverage_kind = "health"

    @health_plans = $quote_shop_health_plans
    @health_selectors = $quote_shop_health_selectors
    @health_plan_quote_criteria  = $quote_shop_health_plan_features.to_json

    @dental_selectors = $quote_shop_dental_selectors
    @dental_plans = $quote_shop_dental_plans
    @dental_plans_count = @dental_plans.count

    dental_plan_quote_criteria  = $quote_shop_dental_plan_features.to_json

    @bp_hash = {'employee':50, 'spouse': 0, 'domestic_partner': 0, 'child_under_26': 0, 'child_26_and_over': 0}
    @benefit_pcts_json = @bp_hash.to_json
    @quote_criteria = []

    @quote_on_page.quote_relationship_benefits.each{|bp| @bp_hash[bp.relationship] = bp.premium_pct}
    roster_premiums = @quote_on_page.roster_cost_all_plans
    @roster_premiums_json = roster_premiums.to_json
    dental_roster_premiums =  @quote_on_page.roster_cost_all_plans('dental')
    @dental_roster_premiums = dental_roster_premiums.to_json
    @quote_criteria = @quote_on_page.criteria_for_ui
    @benefit_pcts_json = @bp_hash.to_json
  end

  def health_cost_comparison
      #@q =  Quote.find(params[:quote])
      @q = Quote.find(params[:quote_id]).quote_benefit_groups.find(params[:benefit_id]) # NEW
      @quote_results = Hash.new
      @quote_results_summary = Hash.new
      @health_plans = $quote_shop_health_plans
      unless @q.nil?
        roster_premiums = @q.roster_cost_all_plans
        @roster_elected_plan_bounds = PlanCostDecoratorQuote.elected_plans_cost_bounds(@health_plans,
          @q.quote_relationship_benefits, roster_premiums)
        params['plans'].each do |plan_id|
          p = $quote_shop_health_plans.detect{|plan| plan.id.to_s == plan_id}

          detailCost = Array.new
          @q.quote_households.each do |hh|
            pcd = PlanCostDecorator.new(p, hh, @q, p)
            detailCost << pcd.get_family_details_hash.sort_by { |m| [m[:family_id], -m[:age], -m[:employee_contribution]] }
          end

          employer_cost = @q.roster_employer_contribution(p,p)
          @quote_results[p.name] = {:detail => detailCost,
            :total_employee_cost => @q.roster_employee_cost(p,p),
            :total_employer_cost => employer_cost,
            plan_id: plan_id,
            buy_up: PlanCostDecoratorQuote.buy_up(employer_cost, p.metal_level, @roster_elected_plan_bounds)
          }
        end
        @quote_results = @quote_results.sort_by { |k, v| v[:total_employer_cost] }.to_h
      end
    render partial: 'health_cost_comparison'
  end

  def dental_cost_comparison
    render partial: 'dental_cost_comparison', layout: false
  end

  def add_family
    @qhh = Quote.all.first.quote_households.first
    @quote = Quote.find(@qhh.quote)
    respond_to do |format|
      format.js
    end
  end

  def edit
    #find quote to edit
    @quote = Quote.find(params[:id])

    max_family_id = @quote.quote_households.max(:family_id).to_i

    unless params[:duplicate_household].blank? && params[:num_of_dup].blank?
      dup_household = @quote.quote_households.find(params[:duplicate_household]).dup
      dup_household.quote_members.each do |qhm|
        qhm.dob = nil
        qhm.first_name = ""
        qhm.last_name = ""
      end
      for i in 0..params[:num_of_dup].to_i
        temp_household = dup_household.dup
        max_family_id = max_family_id + 1
        temp_household.family_id = max_family_id

        @quote.quote_households << temp_household
      end
    end

    # Create place holder for a new household and new member for the roster
    qhh = QuoteHousehold.new

    # Increment family id so the new place holder contains max + 1
    qhh.family_id = max_family_id + 1

    # Create place holder for new member of household
    qm = QuoteMember.new
    qhh.quote_members << qm
    @quote.quote_households << qhh

    #redirect_to edit_broker_agencies_quote_path(@quote.id)

  end

  def new
    quote = Quote.new

    # Build Default Quote Benefit Group
    qbg = QuoteBenefitGroup.new
    qbg.build_relationship_benefits
    quote.quote_benefit_groups << qbg

    # Assign new quote to current broker
    quote.broker_role_id= current_user.person(:try).broker_role.id

    quote.save(validate: false)
    redirect_to edit_broker_agencies_quote_path(quote.id)
  end

  def update
    @quote = Quote.find(params[:id])

    sanitize_quote_roster_params

    # update current attributs then insert new ones. Both can't be done at the same time.
    update_params = quote_params
    insert_params = quote_params

    update_params[:quote_households_attributes] = update_params[:quote_households_attributes].select {|k,v| update_params[:quote_households_attributes][k][:id].present?}
    insert_params[:quote_households_attributes] = insert_params[:quote_households_attributes].select {|k,v| insert_params[:quote_households_attributes][k][:id].blank?}

    if (@quote.update_attributes(update_params) && @quote.update_attributes(insert_params))
      redirect_to edit_broker_agencies_quote_path(@quote) ,  :flash => { :notice => "Successfully updated the employee roster" }
    else
      #render "edit" , :flash => {:error => "Unable to update the employee roster" }
      redirect_to edit_broker_agencies_quote_path(@quote) ,  :flash => { :error => "Unable to update the employee roster" }
    end
  end

  def create
    @quote = Quote.new(quote_params)

    # Build Default Quote Benefit Group
    @qbg = QuoteBenefitGroup.new
    @qbg.build_relationship_benefits
    @quote.quote_benefit_groups << qbg

    @quote.broker_role_id= current_user.person(:try).broker_role.id
    if @format_errors.present?
      flash[:error]= "#{@format_errors.join(', ')}"
      render "new"  and return
    end
    if @quote.save
      redirect_to  broker_agencies_quotes_root_path ,  :flash => { :notice => "Successfully saved the employee roster" }
    else
      flash[:error]="Unable to save the employee roster : #{@quote.errors.full_messages.join(", ")}"
      render "new"
    end
  end

  def plan_comparison
    standard_component_ids = get_standard_component_ids
    @qhps = Products::QhpCostShareVariance.find_qhp_cost_share_variances(standard_component_ids, @active_year, "Health")
    @sort_by = params[:sort_by]
    order = @sort_by == session[:sort_by_copay] ? -1 : 1
    session[:sort_by_copay] = order == 1 ? @sort_by : ''
    if @sort_by && @sort_by.length > 0
      @sort_by = @sort_by.strip
      sort_array = []
      @qhps.each do |qhp|
        sort_array.push( [qhp, get_visit_cost(qhp,@sort_by)]  )
      end
      sort_array.sort!{|a,b| a[1]*order <=> b[1]*order}
      @qhps = sort_array.map{|item| item[0]}
    end

    if params[:export_to_pdf].present?
      if (plan_keys = params[:plan_keys]).present?
        @standard_plans = []
        plan_keys.split(',').each { |plan_key| @standard_plans << Plan.find(plan_key).hios_id }
        @qhps = []
        @standard_plans.each { |plan_id| @qhps << Products::QhpCostShareVariance
                                                              .find_qhp_cost_share_variances([plan_id], active_year, "Health") }
        @qhps.flatten!
      end
      render pdf: 'plan_comparison_export',
            template: 'broker_agencies/quotes/_plan_comparison_export.html.erb',
            disposition: 'attachment',
            locals: { qhps: @qhps }
    else
      render partial: 'plan_comparision', layout: false, locals: {qhps: @qhps}
    end
  end

  #def show
  #  @quote = Quote.find(params[:id])
  #end

  def build_employee_roster
    @employee_roster = parse_employee_roster_file
    @quote= Quote.new
    if @employee_roster.is_a?(Hash)
      @employee_roster.each do |family_id , members|
        @quote_household = @quote.quote_households.where(:family_id => family_id).first
        @quote_household= QuoteHousehold.new(:family_id => family_id ) if @quote_household.nil?
        members.each do |member|
          @quote_members= QuoteMember.new(:employee_relationship => member[0], :dob => member[1], :first_name => member[2])
          @quote_household.quote_members << @quote_members
        end
        @quote.quote_households << @quote_household
      end
    end
  end

  def upload_employee_roster
  end

  def download_employee_roster
    @quote = Quote.find(params[:id])
    @employee_roster = @quote.quote_households.map(&:quote_members).flatten
    send_data(csv_for(@employee_roster), :type => 'text/csv; charset=iso-8859-1; header=present',
    :disposition => "attachment; filename=Employee_Roster.csv")
  end

  def destroy
    if @quote.destroy
      respond_to do |format|
        format.js { render :text => "deleted Successfully" , :status => 200 }
      end
    end
  end

  def delete_member
    @qh = @quote.quote_households.find(params[:household_id])
    if @qh
      if @qh.quote_members.find(params[:member_id]).delete
        respond_to do |format|
          format.js { render :nothing => true}
        end
      end
    end
  end

  def delete_household
    @qh = @quote.quote_households.find(params[:household_id])
    if @qh.destroy
      respond_to do |format|
        format.js { render :nothing => true }
      end
    end
  end


  def new_household
    @quote = Quote.new
    @quote.quote_households.build
  end

  def update_benefits
    #q = Quote.find(params[:quote_id]) OLD - To be Removed
    q = Quote.find(params[:quote_id]).quote_benefit_groups.find(params[:benefit_id])
    benefits = params[:benefits]
    q.quote_relationship_benefits.each {|b| b.update_attributes!(premium_pct: benefits[b.relationship]) }
    render json: {}
  end

  def get_quote_info

    bp_hash = {}
    #q =  Quote.find(params[:quote
    q = Quote.find(params[:quote_id])
    benefit_groups = q.quote_benefit_groups
    bg = (params[:benefit_group_id] && q.quote_benefit_groups.find(params[:benefit_group_id])) || benefit_groups.first
    summary = {name: q.quote_name,
     status: q.aasm_state.capitalize,
     plan_name: bg.plan && bg.plan.name || 'None',
     dental_plan_name: "bg.dental_plan && bg.dental_plan.name" || 'None',
    }
    bg.quote_relationship_benefits.each{|bp| bp_hash[bp.relationship] = bp.premium_pct}
    render json: {'relationship_benefits' => bp_hash, 'roster_premiums' => bg.roster_cost_all_plans, 'criteria' => JSON.parse(bg.criteria_for_ui), summary: summary}
  end

  def set_plan
    @q = Quote.find(params[:quote_id])

    bg = (params[:benefit_group_id] && @q.quote_benefit_groups.find(params[:benefit_group_id]))

    if params[:plan_id] && bg
      plan = Plan.find(params[:plan_id][8,100])
      elected_plan_choice = ['na', 'Single Plan', 'Single Carrier', 'Metal Level'][params[:elected].to_i]
      bg.plan = plan
      bg.plan_option_kind = elected_plan_choice
      roster_elected_plan_bounds = PlanCostDecoratorQuote.elected_plans_cost_bounds($quote_shop_health_plans,
         bg.quote_relationship_benefits, bg.roster_cost_all_plans)
       case elected_plan_choice
         when 'Single Carrier'
           @offering_param  = plan.name
           bg.published_lowest_cost_plan = roster_elected_plan_bounds[:carrier_low_plan][plan.carrier_profile.abbrev]
           bg.published_highest_cost_plan = roster_elected_plan_bounds[:carrier_high_plan][plan.carrier_profile.abbrev]
         when 'Metal Level'
           @offering_param  = plan.metal_level.capitalize
           bg.published_lowest_cost_plan = roster_elected_plan_bounds[:metal_low_plan][plan.metal_level]
           bg.published_highest_cost_plan = roster_elected_plan_bounds[:metal_high_plan][plan.metal_level]
         else
           @offering_param = ""
           bg.published_lowest_cost_plan = plan
           bg.published_highest_cost_plan = plan
       end
       bg.save
    end

    @benefit_groups = @q.quote_benefit_groups
    respond_to do |format|
      format.html {render partial: 'publish'}
      format.pdf do
          render :pdf => "publised_quote",
                 :template => "/broker_agencies/quotes/_publish.pdf.erb"
      end
    end
  end

  def publish
    @q = Quote.find(params[:quote_id])
    @benefit_groups = @q.quote_benefit_groups
    @offering_param = 'Logic based on plan_option_kind TODO VARUN'
    respond_to do |format|
      format.html {render partial: 'publish'}
      format.pdf do
          render :pdf => "publised_quote",
                 :template => "/broker_agencies/quotes/_publish.pdf.erb"
      end
    end
  end

  def criteria
    if params[:quote_id]
      q = Quote.find(params[:quote_id])
      criteria_for_ui = params[:criteria_for_ui]
      q.update_attributes!(criteria_for_ui: criteria_for_ui ) if criteria_for_ui
      render json: JSON.parse(q.criteria_for_ui)
    else
      render json: []
    end
  end

  def export_to_pdf
    @pdf_url = "/broker_agencies/quotes/download_pdf?"
  end

  def download_pdf
    @standard_plans = []
    params[:plans].each { |plan_key| @standard_plans << Plan.find(plan_key).hios_id }
    @qhps = []
    @standard_plans.each { |plan_id| @qhps << Products::QhpCostShareVariance
                                                            .find_qhp_cost_share_variances([plan_id], Date.today.year, "Health") }
    @qhps.flatten!
    render pdf: 'plan_comparison_export',
           template: 'broker_agencies/quotes/_plan_comparison_export.html.erb',
           disposition: 'attachment',
           locals: { qhps: @qhps }
  end

  def dental_plans_data
    set_dental_plans
  end


private

  def quote_download_link(quote)
    return quote.published? ? view_context.link_to("Download PDF" , publish_broker_agencies_quotes_path(:format => :pdf,:quote_id => quote.id)) : ""
  end

  def employee_relationship_map
    @employee_relationship_map = {"employee" => "Employee", "spouse" => "Spouse", "domestic_partner" => "Domestic Partner", "child_under_26" => "Child"}
  end

  def get_standard_component_ids
    Plan.where(:_id => { '$in': params[:plans] } ).map(&:hios_id)
  end

  def quote_params
    params.require(:quote).permit(
                    :quote_name,
                    :start_on,
                    :broker_role_id,
                    :quote_households_attributes => [ :id, :family_id , :quote_benefit_group_id,
                                       :quote_members_attributes => [ :id, :first_name, :last_name ,:dob,
                                                                      :employee_relationship,:_delete ] ] )
  end

  def format_date_params
    @format_errors=[]
    params[:quote][:start_on] =  Date.strptime(params[:quote][:start_on],"%m/%d/%Y") if params[:quote][:start_on]
    if params[:quote][:quote_households_attributes]
      params[:quote][:quote_households_attributes].values.each do |household_attribute|
        if household_attribute[:quote_members_attributes].present?
          household_attribute[:quote_members_attributes].values.map do |m|
            begin
              m[:dob] = Date.strptime(m[:dob],"%m/%d/%Y") unless m[:dob] && m[:dob].blank?
            rescue Exception => e
              @format_errors << "Error parsing date #{m[:dob]}"
            end
          end
        end
      end
    end
  end



  def sanitize_quote_roster_params

    params[:quote][:quote_households_attributes].each do |key, fid|
      delete_family_key = 1
      unless params[:quote][:quote_households_attributes][key][:quote_members_attributes].nil?
          params[:quote][:quote_households_attributes][key][:quote_members_attributes].each do |k, mid|
            if mid['dob'].blank?
                params[:quote][:quote_households_attributes][key][:quote_members_attributes].delete(k)
            else
              delete_family_key = 0
            end
          end
          params[:quote][:quote_households_attributes].delete(key) if delete_family_key == 1
      else
        params[:quote][:quote_households_attributes].delete(key)
      end
    end
  end

  def employee_roster_group_by_family_id
    params[:employee_roster].inject({}) do  |new_hash,e|
      new_hash[e[1][:family_id]].nil? ? new_hash[e[1][:family_id]] = [e[1]]  : new_hash[e[1][:family_id]] << e[1]
      new_hash
    end
  end

  def find_quote
    @quote = Quote.find(params[:id])
  end

  # TODO JIM Is this used anywhere?
  def find_benefit_group
    @benefit_group = QuoteBenefitGroup.find(params[:id])
  end

  # def parse_employee_roster_file
  #   begin
  #     CSV.parse(params[:employee_roster_file].read) if params[:employee_roster_file].present?
  #   rescue Exception => e
  #     flash[:error] = "Unable to parse the csv file"
  #     #redirect_to :action => "new" and return
  #   end
  # end

  def parse_employee_roster_file
    begin
      roster = Roo::Spreadsheet.open(params[:employee_roster_file])
      sheet = roster.sheet(0)
      sheet_header_row = sheet.row(1)
      column_header_row = sheet.row(2)
      census_employees = {}
      (4..sheet.last_row).each_with_index.map do |i, index|
        row = roster.row(i)
        row[1]="child_under_26" if row[1].downcase == "child"
        if census_employees[row[0].to_i].nil?
          census_employees[row[0].to_i] = [[row[1].split.join('_').downcase,row[8],row[2]]]
        else
          census_employees[row[0].to_i] << [row[1].split.join('_').downcase,row[8],row[2]]
        end
      end
      census_employees
    rescue Exception => e
      puts e.message
      flash[:error] = "Unable to parse the csv file"
      #redirect_to :action => "new" and return
    end
  end

  def csv_for(employee_roster)
    (output = "").tap do
      CSV.generate(output) do |csv|
        csv << ["FamilyID", "Relationship", "DOB"]
        employee_roster.each do |employee|
          csv << [  employee.family_id,
                    employee.employee_relationship,
                    employee.dob
                  ]
        end
      end
    end
  end

  def dollar_value copay
    return 10000 if copay == 'Not Applicable'
    cost = 0
    cost += 1000 if copay.match(/after deductible/)
    return cost if copay.match(/No charge/)
    dollars = copay.match(/(\d+)/)
    cost += (dollars && dollars[1]).to_i || 0
  end

  def get_visit_cost qhp_cost_share_variance, visit_type
    service_visit = qhp_cost_share_variance.qhp_service_visits.detect{|v| visit_type == v.visit_type }
    cost = dollar_value service_visit.copay_in_network_tier_1
  end

  def set_qhp_variables
    @active_year = Date.today.year
    @coverage_kind = "health"
    @visit_types = @coverage_kind == "health" ? Products::Qhp::VISIT_TYPES : Products::Qhp::DENTAL_VISIT_TYPES
  end

  def set_dental_plans
    @dental_plans = Plan.shop_dental_by_active_year(2016)
    @dental_plans_count = Plan.shop_dental_by_active_year(2016).count
    @dental_plans = @dental_plans.by_carrier_profile(params[:carrier_id]) if params[:carrier_id].present? && params[:carrier_id] != 'any'
    @dental_plans = @dental_plans.by_dental_level(params[:dental_level]) if params[:dental_level].present? && params[:dental_level] != 'any'
    @dental_plans = @dental_plans.by_plan_type(params[:plan_type]) if params[:plan_type].present? && params[:plan_type] != 'any'
    @dental_plans = @dental_plans.by_dc_network(params[:dc_network]) if params[:dc_network].present? && params[:dc_network] != 'any'
    @dental_plans = @dental_plans.by_nationwide(params[:nationwide]) if params[:nationwide].present? && params[:nationwide] != 'any'
  end
end