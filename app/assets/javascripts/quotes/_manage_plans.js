QuoteManagePlans = ( function() {
  var available_health_plans = 0
  plan_test = function(plan, criteria){
    result = true
    critters = criteria.length
    for (var j=0; j< critters; j++){
      criteria_type = criteria[j][0]
      criteria_value = criteria[j][1]
      if ((criteria_type == 'carriers') && (criteria_value != plan['carrier_abbrev']))   {result=false; break; }
      if ((criteria_type == 'metals') && (criteria_value != plan['metal']))     {result=false; break; }
      if ((criteria_type == 'plan_types') && (criteria_value != plan['plan_type'])) {result=false; break; }
      if ((criteria_type == 'nationwide') && (criteria_value != plan['nationwide'])) {result=false; break; }
      if ((criteria_type == 'dc_in_network') && (criteria_value != plan['dc_in_network'])) {result=false; break; }
    }
     if (parseInt(plan['deductible']) > deductible_value) {result=false}
    return result
  }
  set_plan_counts = function() {
      $('#show_plan_criteria_count').text('Plans that meet your criteria: ' + String(available_health_plans))
      $('#show_plan_selected_count').text('You have selected ' + String($('.btn.active').size()) +' plans.')
      $('#show_dental_plan_criteria_count').text('Plans that meet your criteria: ' + '13')
      $('#show_dental_plan_selected_count').text('You have selected ' + String($('.btn.active').size()) +' plans.')
  }
  turn_off_criteria = function() {
      $.each($('#feature-mgmt .active'), function(index,value){ $(value).addClass('criteria').removeClass('active') })
  }
  toggle_plans = function(criteria){
    if(criteria.length== 0){
        $.each($('.plan_selectors .active'), function() {
            criteria_type = this.parentNode.id
            criteria_value = this.id
            if (criteria_value != 'any') {criteria.push([criteria_type,criteria_value])}
     })
   }
   else{
      turn_off_criteria()
     for(var i = 0; i<criteria.length; i++){
       $('#' + criteria[i][0] +' #' + criteria[i][1]).addClass('active')
     }
   }
    available_health_plans = 0
    for(var i = 0; i < health_plan_count; i++) {
        plan = window.select_health_plans[i]
        value = "[value~=" + plan['plan_id'] + "]"
        display = plan_test(plan, criteria) ? 'inline' : 'none'
        $(value).parent().css('display', display)
        if (display=='inline') {available_health_plans += 1}
    }   
    $('#x-of-plans').html($('#quote-plan-list > label:visible').length);
    set_plan_counts()
    $.ajax({
      type: 'GET',
      data: {quote_id: $('#quote').val(), criteria_for_ui: JSON.stringify(criteria) },
      url: '/broker_agencies/quotes/criteria.js'
    })
  }
  reset_selected_plans =  function(){
      $.each($('.plan_buttons .btn.active input'), function(){
      $(this).prop('checked', false)
      $(this).parent().removeClass('active')
      })
      set_plan_counts()
      $('[aria-labelledby="compare_costs"]').html('')
      $('[aria-labelledby="compare_benefits"]').html('')
      setTimeout( function(){
        $('[aria-controls="plan-selection-mgmt"]').attr('aria-expanded', true)
        $('#plan-selection-mgmt').addClass('in')
      }, 0)
  }

  return {
    turn_off_criteria: turn_off_criteria,
    toggle_plans: toggle_plans,
    reset_selected_plans: reset_selected_plans,
  }

})();




