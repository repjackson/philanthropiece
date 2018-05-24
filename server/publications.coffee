Meteor.publish 'type', (type)->
    # console.log type
    Docs.find {type: type},
        limit: 20
    
Meteor.publish 'child_docs', (parent_id)->
    Docs.find {parent_id: parent_id},
        limit: 20
    
Meteor.publish 'my_children', (parent_id)->
    Docs.find {
        author_id: Meteor.userId()
        parent_id: parent_id
    }, limit: 10
        
Meteor.publish 'parent_doc', (child_id)->
    child_doc = Docs.findOne child_id
    if child_doc
        Docs.find
            _id: child_doc.parent_id
    

Meteor.publish 'top_posts', ->
    Docs.find {},
        {
            sort: points:-1
            limit: 10
        }

Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id
    
    
Meteor.publish 'user', (user_id)->
    Meteor.users.find user_id
    
    
Meteor.publish 'top_users', ->
    Meteor.users.find()
    
    
    
    
Meteor.publish 'person_by_id', (id)->
    # console.log id
    Meteor.users.find id,
        fields:
            tags: 1
            profile: 1
            points: 1            
            
Meteor.publish 'all_people', ()->
    Meteor.users.find {}
            

Meteor.publish 'people', (selected_people_tags)->
    match = {}
    if selected_people_tags.length > 0 then match.tags = $all: selected_people_tags
    match._id = $ne: @userId
    # match["profile.published"] = true
    Meteor.users.find match,
        limit: 20


Meteor.publish 'people_tags', (selected_people_tags)->
    self = @
    match = {}
    if selected_people_tags.length > 0 then match.tags = $all: selected_people_tags
    match._id = $ne: @userId
    # match["profile.published"] = true

    # console.log match

    people_cloud = Meteor.users.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selected_people_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    # console.log 'cloud, ', people_cloud
    people_cloud.forEach (tag, i) ->
        self.added 'people_tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()
        


Meteor.publish 'user_docs', (username, selected_theme_tags)->
    # console.log selected_theme_tags
    user = Meteor.users.findOne username: username
    Docs.find {
        # type: 'journal'
        author_id: Meteor.userId()
        published: 1
        # tags: $in: selected_theme_tags
        }, sort: timestamp: -1    
        
        
        
# Meteor.publish 'facet', (
#     selected_tags
#     type
#     editing_id
#     )->
    
#         if editing_id
#             Docs.find editing_id
#         else
        
#             self = @
#             match = {}
            
#             # match.tags = $all: selected_tags
    
#             if selected_tags.length > 0 then match.tags = $all: selected_tags
#             if type then match.type = type
            
            
            
#             tag_cloud = Docs.aggregate [
#                 { $match: match }
#                 { $project: tags: 1 }
#                 { $unwind: "$tags" }
#                 { $group: _id: '$tags', count: $sum: 1 }
#                 { $match: _id: $nin: selected_tags }
#                 { $sort: count: -1, _id: 1 }
#                 { $limit:50 }
#                 { $project: _id: 0, name: '$_id', count: 1 }
#                 ]
#             # console.log 'theme tag_cloud, ', tag_cloud
#             tag_cloud.forEach (tag, i) ->
#                 self.added 'tags', Random.id(),
#                     name: tag.name
#                     count: tag.count
#                     index: i
    
#             # doc_results = []
#             subHandle = Docs.find(match, {limit:5, sort: {timestamp:-1, tag_count:1}}).observeChanges(
#                 added: (id, fields) ->
#                     # console.log 'added doc', id, fields
#                     # doc_results.push id
#                     self.added 'docs', id, fields
#                 changed: (id, fields) ->
#                     # console.log 'changed doc', id, fields
#                     self.changed 'docs', id, fields
#                 removed: (id) ->
#                     # console.log 'removed doc', id, fields
#                     # doc_results.pull id
#                     self.removed 'docs', id
#             )
            
#             # for doc_result in doc_results
                
#             # user_results = Meteor.users.find(_id:$in:doc_results).observeChanges(
#             #     added: (id, fields) ->
#             #         # console.log 'added doc', id, fields
#             #         self.added 'docs', id, fields
#             #     changed: (id, fields) ->
#             #         # console.log 'changed doc', id, fields
#             #         self.changed 'docs', id, fields
#             #     removed: (id) ->
#             #         # console.log 'removed doc', id, fields
#             #         self.removed 'docs', id
#             # )
            
            
            
#             # console.log 'doc handle count', subHandle._observeDriver._results
    
#             self.ready()
            
#             self.onStop ()-> subHandle.stop()

        
        
# Meteor.publish 'delta', (match)->
#     console.log match

Meteor.publish 'facet', (
    selected_tags
    selected_keywords
    selected_concepts
    selected_entities
    selected_author_ids=[]
    selected_location_tags
    selected_timestamp_tags
    type
    author_id
    )->
    
        self = @
        match = {}
        
        # match.tags = $all: selected_tags
        if type then match.type = type
        # console.log selected_timestamp_tags

        # if view_private is true
        #     match.author_id = Meteor.userId()
        
        # if view_private is false
        #     match.published = $in: [0,1]

        if selected_tags.length > 0 then match.tags = $all: selected_tags

        if selected_author_ids.length > 0 
            match.author_id = $in: selected_author_ids
        if selected_location_tags.length > 0 then match.location_tags = $all: selected_location_tags
        if selected_keywords.length > 0 then match.watson_keywords = $all: selected_keywords
        if selected_concepts.length > 0 then match.watson_concepts = $all: selected_concepts
        if selected_entities.length > 0 then match.watson_entities = $all: selected_entities
        if selected_timestamp_tags.length > 0 then match.timestamp_tags = $all: selected_timestamp_tags
        

        # if view_private is true then match.author_id = @userId
        # if view_resonates?
        #     if view_resonates is true then match.favoriters = $in: [@userId]
        #     else if view_resonates is false then match.favoriters = $nin: [@userId]
        # if view_read?
        #     if view_read is true then match.read_by = $in: [@userId]
        #     else if view_read is false then match.read_by = $nin: [@userId]
        # if view_published is true
        #     match.published = $in: [1,0]
        # else if view_published is false
        #     match.published = -1
        #     match.author_id = Meteor.userId()
            
        # if view_bookmarked?
        #     if view_bookmarked is true then match.bookmarked_ids = $in: [@userId]
        #     else if view_bookmarked is false then match.bookmarked_ids = $nin: [@userId]
        # if view_complete? then match.complete = view_complete
        # console.log view_complete
        
        
        
        # match.site = Meteor.settings.public.site

        # console.log 'match:', match
        # if view_images? then match.components?.image = view_images
        
        # lightbank types
        # if view_lightbank_type? then match.lightbank_type = view_lightbank_type
        # match.lightbank_type = $ne:'journal_prompt'
        
        # ancestor_ids_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: ancestor_array: 1 }
        #     { $unwind: "$ancestor_array" }
        #     { $group: _id: '$ancestor_array', count: $sum: 1 }
        #     { $match: _id: $nin: selected_ancestor_ids }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: limit }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # # console.log 'theme ancestor_ids_cloud, ', ancestor_ids_cloud
        # ancestor_ids_cloud.forEach (ancestor_id, i) ->
        #     self.added 'ancestor_ids', Random.id(),
        #         name: ancestor_id.name
        #         count: ancestor_id.count
        #         index: i

        theme_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'theme theme_tag_cloud, ', theme_tag_cloud
        theme_tag_cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i



        watson_keyword_cloud = Docs.aggregate [
            { $match: match }
            { $project: watson_keywords: 1 }
            { $unwind: "$watson_keywords" }
            { $group: _id: '$watson_keywords', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'watson cloud, ', watson_keyword_cloud
        watson_keyword_cloud.forEach (keyword, i) ->
            self.added 'watson_keywords', Random.id(),
                name: keyword.name
                count: keyword.count
                index: i
        
        
        watson_concept_cloud = Docs.aggregate [
            { $match: match }
            { $project: watson_concepts: 1 }
            { $unwind: "$watson_concepts" }
            { $group: _id: '$watson_concepts', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'watson cloud, ', watson_concept_cloud
        watson_concept_cloud.forEach (concept, i) ->
            self.added 'watson_concepts', Random.id(),
                name: concept.name
                count: concept.count
                index: i

        timestamp_tags_cloud = Docs.aggregate [
            { $match: match }
            { $project: timestamp_tags: 1 }
            { $unwind: "$timestamp_tags" }
            { $group: _id: '$timestamp_tags', count: $sum: 1 }
            { $match: _id: $nin: selected_timestamp_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'timestamp_tags_cloud, ', timestamp_tags_cloud
        timestamp_tags_cloud.forEach (timestamp_tag, i) ->
            self.added 'timestamp_tags', Random.id(),
                name: timestamp_tag.name
                count: timestamp_tag.count
                index: i
    
    
        # entities_tags_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: entities_tags: 1 }
        #     { $unwind: "$entities_tags" }
        #     { $group: _id: '$entities_tags', count: $sum: 1 }
        #     { $match: _id: $nin: selected_entities_tags }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # # console.log 'entities_tags_cloud, ', entities_tags_cloud
        # entities_tags_cloud.forEach (entities_tag, i) ->
        #     self.added 'entities_tags', Random.id(),
        #         name: entities_tag.name
        #         count: entities_tag.count
        #         index: i
    
    
        # intention_tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: intention_tags: 1 }
        #     { $unwind: "$intention_tags" }
        #     { $group: _id: '$intention_tags', count: $sum: 1 }
        #     { $match: _id: $nin: selected_intention_tags }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 20 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # # console.log 'intention intention_tag_cloud, ', intention_tag_cloud
        # intention_tag_cloud.forEach (intention_tag, i) ->
        #     self.added 'intention_tags', Random.id(),
        #         name: intention_tag.name
        #         count: intention_tag.count
        #         index: i

    
        location_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: location_tags: 1 }
            { $unwind: "$location_tags" }
            { $group: _id: '$location_tags', count: $sum: 1 }
            { $match: _id: $nin: selected_location_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'location location_tag_cloud, ', location_tag_cloud
        location_tag_cloud.forEach (location_tag, i) ->
            self.added 'location_tags', Random.id(),
                name: location_tag.name
                count: location_tag.count
                index: i


        author_match = match
        # author_match.published = 1
    
        author_tag_cloud = Docs.aggregate [
            { $match: author_match }
            { $project: author_id: 1 }
            { $group: _id: '$author_id', count: $sum: 1 }
            { $match: _id: $nin: selected_author_ids }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, text: '$_id', count: 1 }
            ]
    
    
        # console.log author_tag_cloud
        
        # author_objects = []
        # Meteor.users.find _id: $in: author_tag_cloud.
    
        author_tag_cloud.forEach (author_id) ->
            self.added 'author_ids', Random.id(),
                text: author_id.text
                count: author_id.count

        # found_docs = Docs.find(match).fetch()
        # console.log 'match', match
        # console.log 'found_docs', found_docs
        # found_docs.forEach (found_doc) ->
        #     self.added 'docs', doc._id, fields
        #         text: author_id.text
        #         count: author_id.count
        
        # doc_results = []
        subHandle = Docs.find(match, {limit:20, sort: timestamp:-1}).observeChanges(
            added: (id, fields) ->
                # console.log 'added doc', id, fields
                # doc_results.push id
                self.added 'docs', id, fields
            changed: (id, fields) ->
                # console.log 'changed doc', id, fields
                self.changed 'docs', id, fields
            removed: (id) ->
                # console.log 'removed doc', id, fields
                # doc_results.pull id
                self.removed 'docs', id
        )
        
        # for doc_result in doc_results
            
        # user_results = Meteor.users.find(_id:$in:doc_results).observeChanges(
        #     added: (id, fields) ->
        #         # console.log 'added doc', id, fields
        #         self.added 'docs', id, fields
        #     changed: (id, fields) ->
        #         # console.log 'changed doc', id, fields
        #         self.changed 'docs', id, fields
        #     removed: (id) ->
        #         # console.log 'removed doc', id, fields
        #         self.removed 'docs', id
        # )
        
        
        
        # console.log 'doc handle count', subHandle

        self.ready()
        
        self.onStop ()-> subHandle.stop()

# # Meteor.publish 'ancestor_id_docs', (ancestor_ids)->
# #     console.log ancestor_ids
# #     # Docs.find
# #     #     _id: $in: ancestor_ids




# # Meteor.publish 'ancestor_ids', (doc_id, username)->
# #     match = {}
# #     self = @
# #     if doc_id
# #         # doc = Docs.findOne doc_id
# #         match._id = doc_id
# #     if username
# #         user = Meteor.users.findOne username:username
# #         match.author_id = user._id
        
# #     match.ancestor_array = $exists:true    
# #     # match._id = doc_id
# #     # console.log match
# #     # one_child = Docs.findOne(parent_id:doc_id)
# #     # if one_child
# #     #     match_array = one_child.ancestor_array
# #     #     children = Docs.find(parent_id:one_child._id).fetch()
# #     #     for child in children 
# #     #         match_array.push child._id
# #     # else
# #     #     match_array = doc.ancestor_array
# #     # match.parent_id = $in:match_array
        
# #     # console.log 'match',match
# #     # if selected_ancestor_ids.length > 0 then match.ancestor_array = $all: selected_ancestor_ids
# #     ancestor_ids_cloud = Docs.aggregate [
# #         { $match: match }
# #         { $project: ancestor_array: 1 }
# #         { $unwind: "$ancestor_array" }
# #         { $group: _id: '$ancestor_array', count: $sum: 1 }
# #         # { $match: _id: $nin: selected_ancestor_ids }
# #         { $sort: count: -1, _id: 1 }
# #         { $limit: 10 }
# #         { $project: _id: 0, name: '$_id', count: 1 }
# #         ]
# #     # console.log 'ancestor_ids_cloud, ', ancestor_ids_cloud
# #     ancestor_ids_cloud.forEach (ancestor_id, i) ->
# #         self.added 'ancestor_ids', Random.id(),
# #             name: ancestor_id.name
# #             count: ancestor_id.count
# #             index: i

# #     ancestor_doc_ids =  _.pluck ancestor_ids_cloud, 'name'

# #     # if username
# #     subHandle = Docs.find( {_id:$in:ancestor_doc_ids}, {limit:20, sort: timestamp:-1}).observeChanges(
# #         added: (id, fields) ->
# #             # console.log 'added doc', id, fields
# #             # doc_results.push id
# #             self.added 'docs', id, fields
# #         changed: (id, fields) ->
# #             # console.log 'changed doc', id, fields
# #             self.changed 'docs', id, fields
# #         removed: (id) ->
# #             # console.log 'removed doc', id, fields
# #             # doc_results.pull id
# #             self.removed 'docs', id
# #     )

# #     self.ready()
    
# #     self.onStop ()-> subHandle.stop()


# # # Meteor.publish 'parent_ids', (username, selected_parent_id)->
# # #         parent_tag_cloud = Docs.aggregate [
# # #             { $match: author_id:Meteor.userId() }
# # #             { $project: parent_id: 1 }
# # #             # { $unwind: "$tags" }
# # #             { $group: _id: '$parent_id', count: $sum: 1 }
# # #             { $match: _id: $nin: selected_tags }
# # #             { $sort: count: -1, _id: 1 }
# # #             { $limit: 20 }
# # #             { $project: _id: 0, name: '$_id', count: 1 }
# # #             ]
# # #         # console.log 'theme parent_tag_cloud, ', parent_tag_cloud
# # #         parent_tag_cloud.forEach (tag, i) ->
# # #             self.added 'tags', Random.id(),
# # #                 name: tag.doc_id
# # #                 count: tag.count
# # #                 index: i
# Meteor.publish 'delta', (match)->
#     console.log match

# Meteor.publish 'facet', (
#     selected_tags
#     selected_author_ids=[]
#     selected_location_tags
#     selected_intention_tags
#     selected_timestamp_tags
#     type
#     author_id
#     parent_id
#     tag_limit
#     doc_limit
#     # sort_object
#     view_private
#     )->
    
#         self = @
#         match = {}
        
#         # match.tags = $all: selected_tags
#         if type then match.type = type
#         if parent_id then match.parent_id = parent_id

#         # if view_private is true
#         #     match.author_id = Meteor.userId()
        
#         # if view_private is false
#         #     match.published = $in: [0,1]

#         if selected_tags.length > 0 then match.tags = $all: selected_tags

#         if selected_author_ids.length > 0 
#             match.author_id = $in: selected_author_ids
#             match.published = 1
#         if selected_location_tags.length > 0 then match.location_tags = $all: selected_location_tags
#         if selected_intention_tags.length > 0 then match.intention_tags = $all: selected_intention_tags
#         if selected_timestamp_tags.length > 0 then match.timestamp_tags = $all: selected_timestamp_tags
        
#         if tag_limit then limit=tag_limit else limit=50
#         if author_id then match.author_id = author_id

#         # if view_private is true then match.author_id = @userId
#         # if view_resonates?
#         #     if view_resonates is true then match.favoriters = $in: [@userId]
#         #     else if view_resonates is false then match.favoriters = $nin: [@userId]
#         # if view_read?
#         #     if view_read is true then match.read_by = $in: [@userId]
#         #     else if view_read is false then match.read_by = $nin: [@userId]
#         # if view_published is true
#         #     match.published = $in: [1,0]
#         # else if view_published is false
#         #     match.published = -1
#         #     match.author_id = Meteor.userId()
            
#         # if view_bookmarked?
#         #     if view_bookmarked is true then match.bookmarked_ids = $in: [@userId]
#         #     else if view_bookmarked is false then match.bookmarked_ids = $nin: [@userId]
#         # if view_complete? then match.complete = view_complete
#         # console.log view_complete
        
        
        
#         # match.site = Meteor.settings.public.site

#         console.log 'match:', match
#         # if view_images? then match.components?.image = view_images
        
#         # lightbank types
#         # if view_lightbank_type? then match.lightbank_type = view_lightbank_type
#         # match.lightbank_type = $ne:'journal_prompt'
        
#         # ancestor_ids_cloud = Docs.aggregate [
#         #     { $match: match }
#         #     { $project: ancestor_array: 1 }
#         #     { $unwind: "$ancestor_array" }
#         #     { $group: _id: '$ancestor_array', count: $sum: 1 }
#         #     { $match: _id: $nin: selected_ancestor_ids }
#         #     { $sort: count: -1, _id: 1 }
#         #     { $limit: limit }
#         #     { $project: _id: 0, name: '$_id', count: 1 }
#         #     ]
#         # # console.log 'theme ancestor_ids_cloud, ', ancestor_ids_cloud
#         # ancestor_ids_cloud.forEach (ancestor_id, i) ->
#         #     self.added 'ancestor_ids', Random.id(),
#         #         name: ancestor_id.name
#         #         count: ancestor_id.count
#         #         index: i

#         theme_tag_cloud = Docs.aggregate [
#             { $match: match }
#             { $project: tags: 1 }
#             { $unwind: "$tags" }
#             { $group: _id: '$tags', count: $sum: 1 }
#             { $match: _id: $nin: selected_tags }
#             { $sort: count: -1, _id: 1 }
#             { $limit: limit }
#             { $project: _id: 0, name: '$_id', count: 1 }
#             ]
#         # console.log 'theme theme_tag_cloud, ', theme_tag_cloud
#         theme_tag_cloud.forEach (tag, i) ->
#             self.added 'tags', Random.id(),
#                 name: tag.name
#                 count: tag.count
#                 index: i



#         # watson_keyword_cloud = Docs.aggregate [
#         #     { $match: match }
#         #     { $project: watson_keywords: 1 }
#         #     { $unwind: "$watson_keywords" }
#         #     { $group: _id: '$watson_keywords', count: $sum: 1 }
#         #     { $match: _id: $nin: selected_tags }
#         #     { $sort: count: -1, _id: 1 }
#         #     { $limit: limit }
#         #     { $project: _id: 0, name: '$_id', count: 1 }
#         #     ]
#         # # console.log 'cloud, ', cloud
#         # watson_keyword_cloud.forEach (keyword, i) ->
#         #     self.added 'watson_keywords', Random.id(),
#         #         name: keyword.name
#         #         count: keyword.count
#         #         index: i

#         timestamp_tags_cloud = Docs.aggregate [
#             { $match: match }
#             { $project: timestamp_tags: 1 }
#             { $unwind: "$timestamp_tags" }
#             { $group: _id: '$timestamp_tags', count: $sum: 1 }
#             { $match: _id: $nin: selected_timestamp_tags }
#             { $sort: count: -1, _id: 1 }
#             { $limit: 10 }
#             { $project: _id: 0, name: '$_id', count: 1 }
#             ]
#         # console.log 'intention timestamp_tags_cloud, ', timestamp_tags_cloud
#         timestamp_tags_cloud.forEach (timestamp_tag, i) ->
#             self.added 'timestamp_tags', Random.id(),
#                 name: timestamp_tag.name
#                 count: timestamp_tag.count
#                 index: i
    
    
#         intention_tag_cloud = Docs.aggregate [
#             { $match: match }
#             { $project: intention_tags: 1 }
#             { $unwind: "$intention_tags" }
#             { $group: _id: '$intention_tags', count: $sum: 1 }
#             { $match: _id: $nin: selected_intention_tags }
#             { $sort: count: -1, _id: 1 }
#             { $limit: limit }
#             { $project: _id: 0, name: '$_id', count: 1 }
#             ]
#         # console.log 'intention intention_tag_cloud, ', intention_tag_cloud
#         intention_tag_cloud.forEach (intention_tag, i) ->
#             self.added 'intention_tags', Random.id(),
#                 name: intention_tag.name
#                 count: intention_tag.count
#                 index: i

    
#         location_tag_cloud = Docs.aggregate [
#             { $match: match }
#             { $project: location_tags: 1 }
#             { $unwind: "$location_tags" }
#             { $group: _id: '$location_tags', count: $sum: 1 }
#             { $match: _id: $nin: selected_location_tags }
#             { $sort: count: -1, _id: 1 }
#             { $limit: limit }
#             { $project: _id: 0, name: '$_id', count: 1 }
#             ]
#         # console.log 'location location_tag_cloud, ', location_tag_cloud
#         location_tag_cloud.forEach (location_tag, i) ->
#             self.added 'location_tags', Random.id(),
#                 name: location_tag.name
#                 count: location_tag.count
#                 index: i


#         author_match = match
#         author_match.published = 1
    
#         author_tag_cloud = Docs.aggregate [
#             { $match: author_match }
#             { $project: author_id: 1 }
#             { $group: _id: '$author_id', count: $sum: 1 }
#             { $match: _id: $nin: selected_author_ids }
#             { $sort: count: -1, _id: 1 }
#             { $limit: limit }
#             { $project: _id: 0, text: '$_id', count: 1 }
#             ]
    
    
#         # console.log author_tag_cloud
        
#         # author_objects = []
#         # Meteor.users.find _id: $in: author_tag_cloud.
    
#         author_tag_cloud.forEach (author_id) ->
#             self.added 'author_ids', Random.id(),
#                 text: author_id.text
#                 count: author_id.count

#         # found_docs = Docs.find(match).fetch()
#         # found_docs.forEach (found_doc) ->
#         #     self.added 'docs', doc._id, fields
#         #         text: author_id.text
#         #         count: author_id.count
        
#         # doc_results = []
#         int_doc_limit = parseInt doc_limit
#         subHandle = Docs.find(match, {limit:20, sort: timestamp:-1}).observeChanges(
#             added: (id, fields) ->
#                 # console.log 'added doc', id, fields
#                 # doc_results.push id
#                 self.added 'docs', id, fields
#             changed: (id, fields) ->
#                 # console.log 'changed doc', id, fields
#                 self.changed 'docs', id, fields
#             removed: (id) ->
#                 # console.log 'removed doc', id, fields
#                 # doc_results.pull id
#                 self.removed 'docs', id
#         )
        
#         # for doc_result in doc_results
            
#         # user_results = Meteor.users.find(_id:$in:doc_results).observeChanges(
#         #     added: (id, fields) ->
#         #         # console.log 'added doc', id, fields
#         #         self.added 'docs', id, fields
#         #     changed: (id, fields) ->
#         #         # console.log 'changed doc', id, fields
#         #         self.changed 'docs', id, fields
#         #     removed: (id) ->
#         #         # console.log 'removed doc', id, fields
#         #         self.removed 'docs', id
#         # )
        
        
        
#         # console.log 'doc handle count', subHandle

#         self.ready()
        
#         self.onStop ()-> subHandle.stop()

# # Meteor.publish 'ancestor_id_docs', (ancestor_ids)->
# #     console.log ancestor_ids
# #     # Docs.find
# #     #     _id: $in: ancestor_ids




# # Meteor.publish 'ancestor_ids', (doc_id, username)->
# #     match = {}
# #     self = @
# #     if doc_id
# #         # doc = Docs.findOne doc_id
# #         match._id = doc_id
# #     if username
# #         user = Meteor.users.findOne username:username
# #         match.author_id = user._id
        
# #     match.ancestor_array = $exists:true    
# #     # match._id = doc_id
# #     # console.log match
# #     # one_child = Docs.findOne(parent_id:doc_id)
# #     # if one_child
# #     #     match_array = one_child.ancestor_array
# #     #     children = Docs.find(parent_id:one_child._id).fetch()
# #     #     for child in children 
# #     #         match_array.push child._id
# #     # else
# #     #     match_array = doc.ancestor_array
# #     # match.parent_id = $in:match_array
        
# #     # console.log 'match',match
# #     # if selected_ancestor_ids.length > 0 then match.ancestor_array = $all: selected_ancestor_ids
# #     ancestor_ids_cloud = Docs.aggregate [
# #         { $match: match }
# #         { $project: ancestor_array: 1 }
# #         { $unwind: "$ancestor_array" }
# #         { $group: _id: '$ancestor_array', count: $sum: 1 }
# #         # { $match: _id: $nin: selected_ancestor_ids }
# #         { $sort: count: -1, _id: 1 }
# #         { $limit: 10 }
# #         { $project: _id: 0, name: '$_id', count: 1 }
# #         ]
# #     # console.log 'ancestor_ids_cloud, ', ancestor_ids_cloud
# #     ancestor_ids_cloud.forEach (ancestor_id, i) ->
# #         self.added 'ancestor_ids', Random.id(),
# #             name: ancestor_id.name
# #             count: ancestor_id.count
# #             index: i

# #     ancestor_doc_ids =  _.pluck ancestor_ids_cloud, 'name'

# #     # if username
# #     subHandle = Docs.find( {_id:$in:ancestor_doc_ids}, {limit:20, sort: timestamp:-1}).observeChanges(
# #         added: (id, fields) ->
# #             # console.log 'added doc', id, fields
# #             # doc_results.push id
# #             self.added 'docs', id, fields
# #         changed: (id, fields) ->
# #             # console.log 'changed doc', id, fields
# #             self.changed 'docs', id, fields
# #         removed: (id) ->
# #             # console.log 'removed doc', id, fields
# #             # doc_results.pull id
# #             self.removed 'docs', id
# #     )

# #     self.ready()
    
# #     self.onStop ()-> subHandle.stop()


# # # Meteor.publish 'parent_ids', (username, selected_parent_id)->
# # #         parent_tag_cloud = Docs.aggregate [
# # #             { $match: author_id:Meteor.userId() }
# # #             { $project: parent_id: 1 }
# # #             # { $unwind: "$tags" }
# # #             { $group: _id: '$parent_id', count: $sum: 1 }
# # #             { $match: _id: $nin: selected_tags }
# # #             { $sort: count: -1, _id: 1 }
# # #             { $limit: limit }
# # #             { $project: _id: 0, name: '$_id', count: 1 }
# # #             ]
# # #         # console.log 'theme parent_tag_cloud, ', parent_tag_cloud
# # #         parent_tag_cloud.forEach (tag, i) ->
# # #             self.added 'tags', Random.id(),
# # #                 name: tag.doc_id
# # #                 count: tag.count
# # #                 index: i        
        
        
Meteor.publish 'block', (hash)->
    Docs.find {
        type: 'block'
        hash: hash
    },
        fields: 
            hash:1
            type:1
            time:1
            height:1
Meteor.publish 'blocks', ()->
    Docs.find {
        type: 'block'
    },
        fields: 
            hash:1
            type:1
            time:1
            height:1


Meteor.publish 'transaction', (hash)->
    Docs.find {
        type: 'transaction'
        hash: hash
    },        
        fields: 
            hash:1
        
        
        
Meteor.publish 'comments', (parent_id)->
    Docs.find
        type:'comment'
        parent_id:parent_id
        
        
Meteor.publish 'current_user', ->
    Meteor.users.find
        _id: Meteor.userId()

                        
                        
                        
                        