$ ->
  user_role = 'Non-Attorney Fiduciary'
  # replacement seller
  repls_contact_id = $(document).find('input.repls_contact_id').val()
  repls_contact_type = ""
  repls_name = ""
  repls_info_html = ""

  # relinquishing purchaser
  relinp_id = $(document).find('input.relinp_id').val()
  relinp_info_html = ""
  
  # relinqushing seller
  exchangor_entity_id = $(document).find('input.exchangor_entity_id').val()
  exchangor_entity_type = $(document).find('input.exchangor_entity_type').val()
  exchangor_name = $(document).find('input.exchangor_name').val()
  exchangor_info_html = ''
  
  # relinquishing property
  purchased_property_id = $(document).find('input.purchased_property_id').val()
  purchased_info_html = ''
  
  # replacement property
  replacement_property_id = $(document).find('input.replacement_property_id').val()
  replacement_property_info_html = ''

  # show initial participants modal
  if $(document).find('#md-initial-participants').length > 0
    $(document).find('#md-initial-participants').modal('show')

  if $(document).find('#show_initial_sign_in_modal').val() == 'true'
    # show initial sign in modal
    $(document).find('#md-welcome').modal('show')
  else
    # show landing page modal
    if $(document).find('#is_show_landing_page').val() == 'true'
      $(document).find('#md-landing').modal('show')
  
  $(document).find('#md-welcome .business_modal').on 'click', ->
    $(document).find('#md-welcome').modal('hide')
    $(document).find('#md-user-role .go-next').data('target-modal', '#md-business')
    $(document).find('#md-user-role').modal('show')
        
  $(document).find('#md-welcome .individual_modal').on 'click', ->
    $(document).find('#md-welcome').modal('hide')
    $(document).find('#md-user-role .go-next').data('target-modal', '#md-individual')
    $(document).find('#md-user-role').modal('show')
    
  $(document).find('#md-user-role .go-next').on 'click', -> 
    if $(this).data('target-modal') == '#md-business'
      if user_role == 'Attorney'
        # begin temporary command
        $(document).find('#md-business form.create_contact').show()
        $(document).find('#md-business form.under_construction').hide()
        # end
        
        $(document).find('.business-step-title').text('Legal Setup')
        $(document).find('#md-business .law-firm-detail input, #md-business .law-firm-detail select').prop('disabled', false)
        $(document).find('#md-business .law-firm-detail .new_firm_field').hide()
        $(document).find('#md-business .shared-field').hide()
        $(document).find('#md-business .law-firm-detail').removeClass('hide')
        
        $(document).find('#md-business .business-detail input').prop('disabled', 'disabled')
        $(document).find('#md-business .business-detail').addClass('hide')
      else if user_role == 'Normal User'
        $(document).find('.business-step-title').text('Fiduciary Setup')
        
        # begin temporary command
        $(document).find('#md-business form.create_contact').hide()
        $(document).find('#md-business form.under_construction').show()
        # end
      else
        # begin temporary command
        $(document).find('#md-business form.create_contact').show()
        $(document).find('#md-business form.under_construction').hide()
        # end
        $(document).find('.business-step-title').text('Business Setup')
        $(document).find('#md-business .law-firm-detail input, #md-business .law-firm-detail select').prop('disabled', 'disabled')
        $(document).find('#md-business .law-firm-detail').addClass('hide')

        $(document).find('#md-business .business-detail input').prop('disabled', false)
        $(document).find('#md-business .business-detail').removeClass('hide')
        $(document).find('#md-business .shared-field').show()

    # clear form fields
    $(document).find('form.create_contact select.existing_firm').val($(document).find('form.create_contact select.existing_firm option:first').val())
    $(document).find('form.create_contact input[type="text"]').val('')
    
  $(document).find('.go-back, .go-next').on 'click', (e) ->
    e.preventDefault()
    $(this).closest('.modal').modal('hide')
    if $(this).data('target') == '#md-welcome'
      $(document).find('.top_nav .navbar-nav .client-module').html('Clients <span class="fa fa-plus-circle" id="add-client"></span>')
    $(document).find($(this).data('target-modal')).modal('show')

  $(document).find('.attorney_user, .fiduciary_user, .property_owner').on 'click', ->
    if $('.attorney_user').is(':checked')
      user_role = 'Attorney'
      $(document).find('.top_nav .navbar-nav .client-module').html('Clients <span class="fa fa-plus-circle" id="add-client"></span>')
    else if $('.fiduciary_user').is(':checked')
      user_role = 'Normal User'
      $(document).find('.top_nav .navbar-nav .client-module').html('Clients <span class="fa fa-plus-circle" id="add-client"></span>')
    else
      user_role = 'Non-Attorney Fiduciary'
      $(document).find('.top_nav .navbar-nav .client-module').html('Holdings <span class="fa fa-plus-circle" id="add-client"></span>')
  
  $(document).find('select.existing_firm').on 'change', ->
    if $('.existing_firm option:selected').text() == ""
      $(document).find('#md-business .law-firm-detail .new_firm_field').hide()
      $(document).find('#md-business .shared-field').hide()
    else
      if $('.existing_firm option:selected').text() == "Add"
        $('.law-firm-detail .new_firm_field input').prop('disabled', false)
        $('.law-firm-detail .new_firm_field').show()
      else
        $('.law-firm-detail .new_firm_field input').prop('disabled', 'disabled')
        $('.law-firm-detail .new_firm_field').hide()
      $(document).find('#md-business .shared-field').show()

  $(document).find('.create_contact').submit (e) ->
    e.preventDefault()
    if $(this).closest('.md-user-setup').attr('id') == 'md-business'
      if user_role == 'Attorney' && !$(this).find('select.existing_firm').val()
        $.notify 'Please select law firm!', 'error'
        return false
    back_modal = $(this).closest('.md-user-setup').attr('id')
    $(this).find('input[name="user_type"]').val(user_role)
    contact_info = $(this).serialize()
    $.ajax
      url: '/users/set_contact_info/'
      type: 'POST'
      dataType: 'json'
      data: contact_info
      success: (data) ->
        if data.status
          $(document).find('.md-user-setup').modal('hide')
          if data.user_type == 'Non-Attorney Fiduciary'
            $(document).find('.top_nav .navbar-nav .client-module').html('Holdings <span class="fa fa-plus-circle" id="add-client"></span>')
          else
            $(document).find('.top_nav .navbar-nav .client-module').html('Clients <span class="fa fa-plus-circle" id="add-client"></span>')
          
          window.location.href = '/'
        else
          $.notify "Failed", "error"

  $(document).find('#md-landing .close').on 'click', ->
    window.location.href = $(this).data('back-url')

  $(document).find('.exchangor-wrapper .create-initial-client-type').on 'click', ->
    if $(document).find('.exchangor-wrapper form input[name="entity[name]"]').val() == ''
      sweetAlert('First input the Name', '', 'info')
      return false
    $(document).find('#md-add-initial-client').modal('show')
  
  $(document).find('.is_entity_business').on 'click', ->
    $(document).find('.exchangor-wrapper form .form-group').show()
    $(document).find('.exchangor-wrapper .entity-business-detail').show()
    
    $(document).find('.exchangor-wrapper .entity-individual-detail input').val('')
    $(document).find('.exchangor-wrapper .entity-individual-detail').hide()
    
    $(document).find('.exchangor-wrapper form input[name="entity_type"]').val('business')

  $(document).find('.is_entity_individual').on 'click', ->
    $(document).find('.exchangor-wrapper form .form-group').show()
    $(document).find('.exchangor-wrapper .entity-business-detail input').val('')
    $(document).find('.exchangor-wrapper .entity-business-detail').hide()

    $(document).find('.exchangor-wrapper .entity-individual-detail').show()
    
    $(document).find('.exchangor-wrapper form input[name="entity_type"]').val('individual')

  $(document).find('#md-add-initial-client ul li').on 'click', ->
    entity_em = $(this)
    form = $(document).find('.exchangor-wrapper form')
    if form.find('input[name="entity[name]"]').val() != ''
      entity_business_name = form.find('input[name="entity[name]"]').val()
    else
      return false
    switch entity_em.data('entity-name')
      when 'Sole Proprietorship'
        legal_ending = ''
        legal_ending_html = 'Sole Proprietorship'
      when 'Partnership'
        legal_ending = 'Partners'
        legal_ending_html = 'Partnership'
      when 'LLC'
        legal_ending = 'LLC'
        legal_ending_html = 'LLC'
      when 'Limited Partnership'
        legal_ending = 'LP'
        legal_ending_html = 'LP'
      when 'Corporation'
        legal_ending = ''
        legal_ending_html = '<select class="select_auto corporation_legal_ending"><option>Inc</option><option>Corp</option><option>Ltd</option></select>'

    entity_params =  {}
    entity_params['entity[name]'] = entity_business_name
    entity_params['entity[type_]'] = entity_em.data('entity-type')
    entity_params['entity[legal_ending]'] = legal_ending
    $.ajax
      url: '/xhr/create_entity'
      type: 'POST'
      dataType: 'json'
      data: entity_params
      success: (data) ->
        if data.id
          exchangor_entity_id = data.id
          exchangor_name = data.name
          exchangor_info_html = '<span class="text-success">' + exchangor_name + ', ' + legal_ending_html + ' will be your first Exchangor</span>'
          # $(document).find('.exchangor-wrapper .create-initial-client-type').hide()
          $(document).find('.exchangor-info').html(exchangor_info_html)
          $(document).find('.exchangor-wrapper form').hide()
          
          $(document).find('#md-add-initial-client').modal('hide')
          if exchangor_entity_id && purchased_property_id && relinp_id && repls_contact_id && replacement_property_id
            $(document).find('#completed-ipp').show()
            $(document).find('.final-step').removeAttr('data-dismiss')
            $(document).find('.final-step').attr('href', '/')
            $(document).find('.final-step').text('Done')
          else
            $(document).find('.final-step').text('Skip This Step')
        else
          $.notify "Failed!", "error"
    
  $(document).on 'change', '.corporation_legal_ending', ->
    console.log $(this).find('option:selected').text()
    $.ajax
      url: '/xhr/update_entity'
      type: 'POST'
      dataType: 'json'
      data: {id: exchangor_entity_id, legal_ending: $(this).find('option:selected').text()}
      success: (data) ->
        if data
          console.log 'success'
          
  $(document).find('.is_repls_business').on 'click', ->
    $(document).find('.replacement-seller-wrapper form .form-group').show()
    $(document).find('.replacement-seller-wrapper .repls-business-detail').show()

    $(document).find('.replacement-seller-wrapper .repls-individual-detail input').val('')
    $(document).find('.replacement-seller-wrapper .repls-individual-detail').hide()

    $(document).find('.replacement-seller-wrapper form input[name="contact[is_company]"]').val('true')
    repls_contact_type = 'business'

  $(document).find('.is_repls_individual').on 'click', ->
    $(document).find('.replacement-seller-wrapper form .form-group').show()
    $(document).find('.replacement-seller-wrapper .repls-business-detail input').val('')
    $(document).find('.replacement-seller-wrapper .repls-business-detail').hide()

    $(document).find('.replacement-seller-wrapper .repls-individual-detail').show()
    
    $(document).find('.replacement-seller-wrapper form input[name="contact[is_company]"]').val('false')
    repls_contact_type = 'individual'

  
  $(document).find('.is_relinp_business').on 'click', ->
    $(document).find('.relinquishing-purchaser-wrapper form .form-group').show()
    $(document).find('.relinquishing-purchaser-wrapper .relinp-business-detail').show()
    
    $(document).find('.relinquishing-purchaser-wrapper .relinp-individual-detail input').val('')
    $(document).find('.relinquishing-purchaser-wrapper .relinp-individual-detail').hide()

    $(document).find('.relinquishing-purchaser-wrapper form input[name="contact[is_company]"]').val('true')
    

  $(document).find('.is_relinp_individual').on 'click', ->
    $(document).find('.relinquishing-purchaser-wrapper form .form-group').show()
    $(document).find('.relinquishing-purchaser-wrapper .relinp-business-detail input').val('')
    $(document).find('.relinquishing-purchaser-wrapper .relinp-business-detail').hide()

    $(document).find('.relinquishing-purchaser-wrapper .relinp-individual-detail').show()

    $(document).find('.relinquishing-purchaser-wrapper form input[name="contact[is_company]"]').val('false')

  $(document).find('.entity-individual-detail input').on 'blur keypress', (e)->
    form = $(this).closest('form')
    current_em = $(this)
    if e.type == 'blur' || e.keyCode == 13
      none_empty_inputs = form.find('.entity-individual-detail input').filter ->
          return this.value != ''
      if none_empty_inputs.length != 2
        return false
      
      $.ajax
        url: '/xhr/create_entity'
        type: 'POST'
        dataType: 'json'
        data: form.serialize()
        success: (data) ->
          if data.id
            exchangor_entity_id = data.id
            if data.first_name && data.last_name
              exchangor_name = data.first_name + ' ' + data.last_name
              exchangor_info_html = '<span class="text-success">You have created a data record for ' + exchangor_name + ' to be your first Exchangor.</span>'
              $(document).find('.exchangor-wrapper .create-initial-client-type').hide()
              $(document).find('.exchangor-info').html(exchangor_info_html)
              $(document).find('.exchangor-wrapper form').hide()
              current_em.off('blur')
              
            if exchangor_entity_id && purchased_property_id && relinp_id && repls_contact_id && replacement_property_id
              $(document).find('#completed-ipp').show()
              $(document).find('.final-step').removeAttr('data-dismiss')
              $(document).find('.final-step').attr('href', '/')
              $(document).find('.final-step').text('Next')
            else
              $(document).find('.final-step').text('Skip This Step')
          else
            $.notify "Failed!", "error"
  
  $(document).find('.entity-business-detail input').on 'blur keypress', (e)->
    if e.type == 'blur' || e.keyCode == 13
      if $(this).val() == ''
        sweetAlert('First input the Name', '', 'info')
        return false
      $(document).find('#md-add-initial-client').modal('show')

  $(document).find('.relinp-individual-detail input, .relinp-business-detail input').on 'blur keypress', (e)->
    form = $(this).closest('form')
    current_em = $(this)
    if e.type == 'blur' || e.keyCode == 13
      if $(this).val() != ""
        if form.attr('action') != ""
          action_url = form.attr('action')
          type = 'PUT'
        else
          action_url = '/contacts/'
          type = 'POST'

        $.ajax
          url: action_url
          type: type
          dataType: 'json'
          data: form.serialize()
          success: (data) ->
            if data.id
              form.attr('action', '/contacts/' + data.id)
              relinp_id = data.id
              if data.is_company
                relinp_info_html = '<span class="text-success">You have created a data record for ' + data.company_name + ' to be your first Purchaser.</span>'
              else if data.first_name != '' && data.last_name != ""
                relinp_info_html = '<span class="text-success">You have created a data record for ' + data.first_name + ' ' + data.last_name + ' to be your first Purchaser.</span>'
              if relinp_info_html != ""
                $(document).find('.relinquishing-purchaser-info').html(relinp_info_html)
                $(document).find('.relinquishing-purchaser-wrapper form').hide()
                current_em.off('blur')

              if exchangor_entity_id && purchased_property_id && relinp_id && repls_contact_id && replacement_property_id
                $(document).find('#completed-ipp').show()
                $(document).find('.final-step').removeAttr('data-dismiss')
                $(document).find('.final-step').attr('href', '/')
                $(document).find('.final-step').text('Next')
              else
                $(document).find('.final-step').text('Skip This Step')
            else
              $.notify "Failed!", "error"

  $(document).find('.repls-individual-detail input, .repls-business-detail input').on 'blur keypress', (e)->
    form = $(this).closest('form')
    current_em = $(this)
    if e.type == 'blur' || e.keyCode == 13
      if $(this).val() != ""
        if form.attr('action') != ""
          action_url = form.attr('action')
          type = 'PUT'
        else
          action_url = '/contacts/'
          type = 'POST'

        $.ajax
          url: action_url
          type: type
          dataType: 'json'
          data: form.serialize()
          success: (data) ->
            if data.id
              form.attr('action', '/contacts/' + data.id)
              repls_contact_id = data.id
              if data.is_company
                repls_info_html = '<span class="text-success">You have created a data record for ' + data.company_name + ' to be your first Purchaser.</span>'
                repls_name = data.company_name
              else if data.first_name != '' && data.last_name != ""
                repls_info_html = '<span class="text-success">You have created a data record for ' + data.first_name + ' ' + data.last_name + ' to be your first Purchaser.</span>'
                repls_name = data.first_name + ' ' + data.last_name
              if repls_info_html != ""
                $(document).find('.replacement-seller-info').html(repls_info_html)
                $(document).find('.replacement-seller-wrapper form').hide()
                current_em.off('blur')

              if exchangor_entity_id && purchased_property_id && relinp_id && repls_contact_id && replacement_property_id
                $(document).find('#completed-ipp').show()
                $(document).find('.final-step').removeAttr('data-dismiss')
                $(document).find('.final-step').attr('href', '/')
                $(document).find('.final-step').text('Next')
              else
                $(document).find('.final-step').text('Skip This Step')
            else
              $.notify "Failed!", "error"

  $(document).find('.create-exchangor-property').on 'click', ->
    if parseInt(exchangor_entity_id) == 0 || exchangor_entity_id == undefined
      sweetAlert 'First create your Exchangor', '', 'info'
      return
    
    form = $(document).find('#md-new-property form')
    form.parsley().reset()
    form.find('input').val('')
    form.find('input#ostatus').val('Purchased')
    form.find('input#property_ownership_status').val('Purchased')
    if exchangor_entity_type == 'Individual'
      form.find('input#property_owner_entity_id').val('')
      form.find('input#property_owner_entity_id_indv').val(exchangor_entity_id)
      form.find('input#property_owner_person_is').val('true')
    else
      form.find('input#property_owner_entity_id').val(exchangor_entity_id)
      form.find('input#property_owner_entity_id_indv').val('')
      form.find('input#property_owner_person_is').val('false')
    $(document).find('#md-new-property').modal('show')

  $(document).find('.create-seller-property').on 'click', ->
    if parseInt(repls_contact_id) == 0 || repls_contact_id == undefined
      sweetAlert 'First create your\n Replacement Seller', '', 'info'
      return

    form = $(document).find('#md-new-property form')
    form.parsley().reset()
    form.find('input').val('')
    form.find('input#ostatus').val('Prospective Purchase')
    form.find('input#property_ownership_status').val('Prospective Purchase')
    if repls_contact_type == 'business'
      form.find('input#property_owner_entity_id').val(repls_contact_id)
      form.find('input#property_owner_entity_id_indv').val('')
      form.find('input#property_owner_person_is').val('false')
    else
      form.find('input#property_owner_entity_id').val('')
      form.find('input#property_owner_entity_id_indv').val(repls_contact_id)
      form.find('input#property_owner_person_is').val('true')
    $(document).find('#md-new-property').modal('show')

  $(document).find('#md-new-property form select#property_tenant_id').on 'change', ->
    form = $(document).find('#md-new-property form')
    if $(this).find('option:selected').text() == 'No Tenant'
      $('#property_rent_price').prop('required', false)
    else
      $('#property_rent_price').prop('required', true)
    
    if form.find('#property_location_city').val() != ""
      form.find('#property_title').val($(this).find('option:selected').text() + ', ' + form.find('#property_location_city').val())
    else
      form.find('#property_title').val('')
        
  $(document).find('#md-new-property form #property_location_city').on 'change', ->
    form = $(document).find('#md-new-property form')
    if $(this).val() != ""
      form.find('#property_title').val(form.find('select#property_tenant_id option:selected').text() + ', ' + $(this).val())
    else
      form.find('#property_title').val('')
      
  $(document).on 'ajax:complete', '#md-new-property form', (e, data, status, xhr) ->
    $.notify 'Success', 'success'
    $(document).find('#md-new-property').modal('hide')
    if JSON.parse(data.responseText).ownership_status == 'Purchased'
      purchased_property_id = JSON.parse(data.responseText).id
      purchased_info_html = '<span class="text-success">You have a created a data record for ' + JSON.parse(data.responseText).title + ' to be the first Purchased Property of ' + exchangor_name + '</span>.'
      $(document).find('.create-exchangor-property').parent('p').html(purchased_info_html)
    else
      replacement_property_id = JSON.parse(data.responseText).id
      replacement_property_info_html = '<span class="text-success">You have a created a data record for ' + JSON.parse(data.responseText).title + ' to be the first Prospective Purchase Property of ' + repls_name + '</span>.'
      $(document).find('.create-seller-property').parent('p').html(replacement_property_info_html)
    if exchangor_entity_id && purchased_property_id && relinp_id && repls_contact_id && replacement_property_id
      $(document).find('#completed-ipp').show()
      $(document).find('.final-step').removeAttr('data-dismiss')
      $(document).find('.final-step').attr('href', '/')
      $(document).find('.final-step').text('Next')
    else
      $(document).find('.final-step').text('Skip This Step')
  $(document).find('.new-tenant-button').on 'click', ->
    console.log 'new tenant'
  
  $(document).find('#md-new-property form').parsley(
    errorsContainer: (em) -> 
        $err = em.$element.parents('.form-group').find('.error-msg')
        return $err
  )

  $('table#pt_data_table').DataTable
    'bSort': false
    'bPaginate': true
    'bInfo': false
    'bFilter': false
    'iDisplayLength': 20
    
  $(document).find('#pt_data_table_length').hide()