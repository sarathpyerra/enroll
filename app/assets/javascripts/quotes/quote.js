function inject_quote(quote_id, benefit_group_id, plan_id, elected, cost) {
    console.log('jinect', quote_id, benefit_group_id)
    $.ajax({
      type: "GET",
      url: "/broker_agencies/quotes/set_plan",
      data: {quote_id: quote_id,
             benefit_group_id: benefit_group_id,
             plan_id: plan_id,
             elected: elected,
             cost: cost},
      success: function(response){
        $('#publish-quote').html(response);
      }
    })    
}

function set_quote_toolbar(summary) {
  $('#quote-name').html(summary['name'])
  $('#quote-status').html(summary['status'])
  $('#quote-plan-name').html(summary['plan_name'])
  $('#quote-dental-plan-name').html(summary['dental_plan_name'])
}
function show_benefit_group(quote_id, benefit_group_id){
  QuotePageLoad.configure_benefit_group(quote_id, benefit_group_id)
  inject_quote(quote_id, benefit_group_id)
  QuotePageLoad.page_load_listeners()
  slider_listeners()
    }
function viewDetails($thisObj) {
  if ( $thisObj.hasClass('view') ) {
    $thisObj.html('Hide Details <i class="fa fa-chevron-up fa-lg"></i>');
    $thisObj.removeClass("view");
  } else {
    $thisObj.html('View Details <i class="fa fa-chevron-down fa-lg"></i>');
    $thisObj.addClass("view");
  }
}