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
function load_quote_listeners() {
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
        open_quote()
    })
}
function set_quote_toolbar(summary) {
  $('#quote-name').html(summary['name'])
  $('#quote-status').html(summary['status'])
  $('#quote-plan-name').html(summary['plan_name'])
  $('#quote-dental-plan-name').html(summary['dental_plan_name'])
}
function quote_change(quote_id, benefit_group_id){
       console.log('also', quote_id, benefit_group_id )
       console.log('change',$("#quote_id").val())
       if(quote_id == 'No quote'){return}
        $.ajax({
          type: 'GET',
          data: {quote_id: quote_id, benefit_group_id: benefit_group_id},
          url: '/broker_agencies/quotes/get_quote_info.js'
        }).done(function(response){
            window.relationship_benefits = response['relationship_benefits']
            window.roster_premiums = response['roster_premiums']
            turn_off_criteria()
            toggle_plans(response['criteria'])
            set_plan_costs()
            inject_quote(quote_id, benefit_group_id)
            page_load_listeners()
            set_quote_toolbar(response['summary'])
            slider_listeners()
            set_benefits()
        })
    }
function quote_listeners(){
    $('#quote').on('change', function() {
      quote_change($(this).val())
      $("#plan_comparison_frame").html('')
    })
    $('.view-published').on('click', function(){
      quote_change(this.id)
      open_quote()
    })
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