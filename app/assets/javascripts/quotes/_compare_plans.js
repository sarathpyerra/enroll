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
        $('#compare_plans_table').dragtable({dragaccept: '.movable'});
        $('.cost_sort').on('click', sort_plans);
        _export_compare_plans_listener();
        $('#plan_ids').val(null);
      }
    })
  }
  var _compared_plans_export = function(){
    $.get('/broker_agencies/quotes/export_to_pdf');
  }

  var _compared_plans_export = function(){
    $.get('/broker_agencies/quotes/export_to_pdf');
  }
  var _export_compare_plans_listener = function(){
    $('#pdf_export_compare_plans').on('click', _compared_plans_export);
  }

  var _open_quote = function() {
    $('[aria-controls="quote-mgmt"]').attr('aria-expanded', false)
    $('#quote-mgmt').removeClass('in')
    $('[aria-controls="feature-mgmt"]').attr('aria-expanded', false)
    $('#feature-mgmt').removeClass('in')
    $('[aria-controls="plan-selection-mgmt"]').attr('aria-expanded', false)
    $('#plan-selection-mgmt').removeClass('in')
    $('[aria-controls="dental-plan-selection-mgmt"]').attr('aria-expanded', false)
    $('#dental-plan-selection-mgmt').removeClass('in')
    $('[aria-controls="publish-quote"]').attr('aria-expanded', true)
    $('#publish-quote').addClass('in')
  }
  var _load_quote_listeners= function() {
    console.log('looad')
    $('.publish td').on('click', function(){
        td = $(this)
        quote_id=$('#quote_id').val()
        plan_id=td.parent().attr('id')
        benefit_group_id = $('#benefit_group_select').val()
        elected=td.index()
        cost = td.html()
        console.log(cost, cost.text)
        inject_quote(quote_id, benefit_group_id, plan_id, elected, cost)
        $.ajax({
          type: 'GET',
          data: {quote_id: quote_id},
          url: '/broker_agencies/quotes/get_quote_info.js'
        }).done(function(response){
          set_quote_toolbar(response['summary'])
        })
        _open_quote()
    })
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
        _load_quote_listeners();
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