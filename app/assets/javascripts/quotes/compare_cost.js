function get_health_cost_comparison() {
  plans = selected_plans();
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
      load_quote_listeners();
    }
  })
}
function get_dental_cost_comparison() {
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
