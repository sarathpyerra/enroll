QuotePageLoad = (function() {
  _set_benefits = function() {
      $('#pct_employee').bootstrapSlider('setValue', employee_value = window.relationship_benefits['employee']);
      $('#employee_slide_input').val(employee_value)
      $('#employee_slide_label').html(employee_value + '%')
      $('#pct_spouse').bootstrapSlider('setValue', spouse_value = window.relationship_benefits['spouse']);
      $('#spouse_input').val(spouse_value)
      $('#spouse_label').html(spouse_value + '%')
      $('#pct_domestic_partner').bootstrapSlider('setValue', domestic_value = window.relationship_benefits['domestic_partner']);
      $('#domestic_input').val(domestic_value)
      $('#domestic_label').html(domestic_value + '%')
      $('#pct_child_under_26').bootstrapSlider('setValue', child_value = window.relationship_benefits['child_under_26']);
      $('#child_input').val(child_value)
      $('#child_label').html(child_value + '%')
      $('#dental_pct_employee').bootstrapSlider('setValue',window.relationship_benefits['employee']);
      $('#dental_pct_spouse').bootstrapSlider('setValue', window.relationship_benefits['spouse']);
      $('#dental_pct_domestic_partner').bootstrapSlider('setValue', window.relationship_benefits['domestic_partner']);
      $('#dental_pct_child_under_26').bootstrapSlider('setValue', window.relationship_benefits['child_under_26']);
  }
  configure_benefit_group = function(quote_id, benefit_group_id) {
    $.ajax({
            type: 'GET',
            data: {quote_id: quote_id, benefit_group_id: benefit_group_id},
            url: '/broker_agencies/quotes/get_quote_info.js'
          }).done(function(response){
              window.relationship_benefits = response['relationship_benefits']
              window.roster_premiums = response['roster_premiums']
              QuoteManagePlans.turn_off_criteria()
              deductible_value = parseInt(response['summary']['deductible_value'])
              $('#ex1').bootstrapSlider('setValue', deductible_value)
              $('#ex1_input').val(deductible_value)
              console.log('deductible', deductible_value)
              QuoteManagePlans.toggle_plans(response['criteria'])
              _set_benefits()
              QuoteComparePlans.set_plan_costs()
          })
  }

  var _get_health_cost_comparison =function(){
    var plans = QuoteComparePlans.selected_plans();
    if(plans.length == 0) {
      alert('Please select one or more plans for comparison');
      return;
     }
    $.ajax({
      type: "GET",
      url: "/broker_agencies/quotes/health_cost_comparison",
      data: {
        plans: plans,
        quote_id: $('#quote_id').val(),
        benefit_id: $('#benefit_group_select option:selected').val()
      },
      success: function(response) {
        $('#plan_comparison_frame').html(response);
        QuoteComparePlans.load_publish_listeners();
      }
    })
  }
  var _get_dental_cost_comparison= function() {
    plans = selected_plans();
    quote_id=$('#quote').val();
    if(plans.length == 0) {
      alert('Please select one or more plans for comparison');
      return;
     }
    $.ajax({
      type: "GET",
      url: "/broker_agencies/quotes/dental_cost_comparison",
      data: {plans: plans, quote: quote_id},
      success: function(response) {
        $('#dental_plan_comparison_frame').html(response);
      }
    })
  }

  var page_load_listeners = function() {
      $('.plan_selectors .criteria').on('click',function(){
          selected=this; sibs = $(selected).siblings();
          $.each(sibs, function(){ this.className='criteria' }) ;
          selected.className='active';
          QuoteManagePlans.toggle_plans([])
          QuoteManagePlans.reset_selected_plans()
      })
      $('.dental_carrier, .dental_metal, .dental_plan_type, .dc_network, .nationwide').on('click', function(){
        class_name = $(this).attr('class')
        $("." + class_name).each(function(){
          $(this).removeClass('active1')
        });
        $(this).addClass('active1')
        carrier_id = $('#dental-carriers').find('div.active1').attr('data-carrier')
        dental_level = $('#dental-metals').find('div.active1').attr('id')
        plan_type = $('#dental-plan_types').find('div.active1').attr('id')
        dc_network = $('#dental-dc_in_network').find('div.active1').attr('id')
        nationwide = $('#dental-nationwide').find('div.active1').attr('id')
        quote = $('#quote').val()
        $.get('/broker_agencies/quotes/dental_plans_data/',
          {
            carrier_id: carrier_id,
            dental_level: dental_level,
            plan_type: plan_type,
            dc_network: dc_network,
            nationwide: nationwide,
            quote: quote
          }                                                     );
      });
      $('.plan_buttons .btn').on('click', function() {
          var plan = $(this)
          window.this = plan
          delta = plan.hasClass('active') ? -1 : 1;
          adjusted_count = $('.btn.active').size() + delta
          if ( (adjusted_count > 25) && (delta == 1)  ) {
            alert('You may not select more than 25 plans at a time')
            setTimeout(function(){
              plan.removeClass('active')
              var input = $(plan.children()[0])
              input.prop('checked', false)
            },20)
          }
          else {
           $('#show_plan_selected_count').text('You have selected ' + String(adjusted_count) + ' plans.' )
          }
      })
      $('#benefit_group_select').on('change',
         function(){
          quote_id = $("#quote_id").val()
          benefit_group_id = $(this).val()
          configure_benefit_group(quote_id, benefit_group_id)
      })
      $('#reset_selected').on('click', QuoteManagePlans.reset_selected_plans)
      $('#CostComparison').on('click', _get_health_cost_comparison)
      $('#DentalCostComparison').on('click', _get_dental_cost_comparison)
      $('#PlanComparison').on('click', function(){
         QuoteComparePlans.sort_plans()
      })
  }
    var view_details=function($thisObj) {
    if ( $thisObj.hasClass('view') ) {
      $thisObj.html('Hide Details <i class="fa fa-chevron-up fa-lg"></i>');
      $thisObj.removeClass("view");
    } else {
      $thisObj.html('View Details <i class="fa fa-chevron-down fa-lg"></i>');
      $thisObj.addClass("view");
    }
  }
  return {
      page_load_listeners: page_load_listeners,
      configure_benefit_group: configure_benefit_group,
      view_details: view_details,
  }
})();
