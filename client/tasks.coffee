Template.tasks.onCreated ->
    @autorun => 
        Meteor.subscribe('facet', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='task'
        author_id=null
        )

FlowRouter.route '/tasks', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'tasks'



Template.tasks.helpers
    tasks: -> Docs.find {type: 'task'}
     
     
Template.tasks.onRendered ->
    @autorun =>
        if @subscriptionsReady()
            Meteor.setTimeout ->
                $('.ui.accordion').accordion()
            , 1000
     
            
Template.tasks.events
    'click #add_task': ->
        id = Docs.insert
            type: 'task'
        Session.set 'editing_id', id
        
        

Template.task_card.onCreated ->
    @autorun -> Meteor.subscribe 'doc', Session.get('editing_id')

Template.task_card.helpers
    doc: -> Docs.findOne Session.get('editing_id')
    
    
Template.task_card.events
    'click #delete': ->
        swal {
            title: 'Delete task?'
            # text: 'Confirm delete?'
            type: 'error'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Delete'
            confirmButtonColor: '#da5347'
        }, ->
            doc = Docs.findOne Session.get('editing_id')
            Docs.remove doc._id, ->
                
                