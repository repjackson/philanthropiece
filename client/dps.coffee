
Session.setDefault 'view_mode', 'dp_view'

FlowRouter.route '/dps', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'dps'


Template.view_toggle.events
    'click .toggle_view': ->
        Session.set 'view_mode', @name
        # console.log @name
Template.view_toggle_item.events
    'click .toggle_view': ->
        Session.set 'view_mode', @name
        # console.log @name


Template.dps.onCreated ->
    @autorun => 
        Meteor.subscribe('facet', 
            selected_tags.array()
            []
            []
            []
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='dp'
            author_id=null
        )
        # Meteor.subscribe 'doc', Session.get('editing_id')

Template.dps.helpers
    one_doc: -> Docs.find().count() is 1
    view_mode: -> Session.get 'view_mode'
    viewing_table: -> Session.equals 'view_mode','table'
    editing_id: -> Session.get 'editing_id'
    dps: -> Docs.find({},{limit:5,sort:timestamp:-1})


Template.table_view.helpers
    table_docs: -> Docs.find({},{limit:10,sort:tag_count:1})

    # editing_this: -> Session.equals 'editing_id', @_id

    # is_editing: -> Session.get 'editing_id'

Template.dp_view.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.checkbox').checkbox()
    # #     $('.ui.tabular.menu .item').tab()
    # , 400
    Meteor.setTimeout ->
        $('.ui.tabular.menu .item').tab()
    , 500
