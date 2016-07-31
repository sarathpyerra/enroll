QuoteComparePlans = ( function() {
  // Reference plans selected for comparison
  var selected_plans = function(){
    var plans=[];
    $.each($('.btn.active input'), function(i,item){plans.push( $(item).attr("value"))})
    return(plans)
  }
  var sort_plans = function(){
    var sort_by = $(this.parentNode).text();
    var plans = selected_plans()
    if(plans.length == 0) {
      alert('Please select one or more plans for comparison');
      return;
    }
    $.ajax({
      type: "GET",
      url: "/broker_agencies/quotes/plan_comparison",
      data: {plans: plans, sort_by: sort_by.substring(0, sort_by.length-2)},
      success: function(response) {
        $('#plan_comparison_frame').html(response);
        compare_plans_listeners();
        export_compare_plans_listener();
        $('#plan_ids').val(null);
      }
    })
  }
  var compare_plans_listeners = function (){
    ('#compare_plans_table').dragtable({dragaccept: '.movable'});
    $('.cost_sort').on('click', sort_plans);
  }
  var compared_plans_export = function(){
    $.get('/broker_agencies/quotes/export_to_pdf');
  }
  var export_compare_plans_listener = function(){
    $('#pdf_export_compare_plans').on('click', compared_plans_export);
  }
  var get_health_cost_comparison =function(){
    var plans = selected_plans();
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
  var get_dental_cost_comparison= function() {
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
  return {
    selected_plans: selected_plans,
    sort_plans: sort_plans,
    get_health_cost_comparison: get_health_cost_comparison,
    get_dental_cost_comparison: get_dental_cost_comparison,
  }
})();