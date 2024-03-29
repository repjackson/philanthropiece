Template.doc_emotion.onCreated ->
    Meteor.setTimeout ->
        $('.progress').progress()
    , 1000
    Meteor.setTimeout ->
        $('.ui.accordion').accordion()
    , 1000

Template.small_sentiment.onCreated ->
    Meteor.setTimeout ->
        $('.progress').progress()
    , 1000

Template.small_sentiment.helpers
    sentiment_score_percent: -> 
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()
    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'


Template.doc_emotion.helpers
    sadness_percent: -> (@sadness*100).toFixed()            
    joy_percent: -> (@joy*100).toFixed()   
    disgust_percent: -> (@disgust*100).toFixed()         
    anger_percent: -> (@anger*100).toFixed()
    fear_percent: -> (@fear*100).toFixed()


    sentiment_score_percent: -> 
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()
            
        
    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'
        
    is_positive: -> if @doc_sentiment_label is 'positive' then true else false    


Template.keywords.helpers
    relevance_percent: -> (@relevance*100).toFixed()

    sentiment_percent: -> 
        (@sentiment.score*100).toFixed()

    sadness_percent: -> (@sadness*100).toFixed()            
    # joy_percent: -> (@joy*100).toFixed()   
    disgust_percent: -> (@disgust*100).toFixed()         
    anger_percent: -> (@anger*100).toFixed()
    fear_percent: -> (@fear*100).toFixed()

Template.keywords.onRendered ->
    Meteor.setTimeout ->
        $('.progress').progress()
    , 2000
    Meteor.setTimeout ->
        $('.ui.accordion').accordion()
    , 2000
    

Template.call_watson.events
    'click #call_watson': ->
        # console.log @
        Meteor.call 'call_watson', FlowRouter.getParam('doc_id'), ->




Template.personality.events
    'click #call_personality': ->
        # console.log @
        Meteor.call 'call_personality', @_id, ->


Template.call_visual_analysis.events
    'click #call_visual': ->
        Meteor.call 'call_visual', FlowRouter.getParam('doc_id'), ->

Template.tone.events
    'click #call_tone': ->
        Meteor.call 'call_tone', FlowRouter.getParam('doc_id'), ->



Template.doc_sentiment.onRendered ->
    Meteor.setTimeout ->
        $('.progress').progress()
    , 2000


Template.doc_sentiment.helpers
    sentiment_score_percent: -> 
        if @doc_sentiment_score > 0
            (@doc_sentiment_score*100).toFixed()
        else
            (@doc_sentiment_score*-100).toFixed()
            
        
    sentiment_bar_class: -> if @doc_sentiment_label is 'positive' then 'green' else 'red'
        
    is_positive: -> if @doc_sentiment_label is 'positive' then true else false    