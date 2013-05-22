class AssetHost.ChooserUI
    DefaultOptions:
        dropEl: "#my_assets"
        browser: ''
        saveButton: 1
        assets: true
        uploads: true
        limit: 0
        uploadPath: "#{AssetHost.PATH_PREFIX}/a/assets/upload"

    #----------

    constructor: (options = {}) ->
        @options = _.defaults options, @DefaultOptions
        
        # add in events
        _.extend @, Backbone.Events
        
        # do we have an asset browser to attach to?
        @browser = @options.browser || false 
        
        @drop = $( @options['dropEl'] )
        
        # hang onto whatever starts out in drop... we'll use it when it's empty
        @emptyMsg = $ '<div/>', html: @drop.html()
        @drop.html @emptyMsg
        
        # set up collection and view to manage assets
        @myassets       = new AssetHost.Models.Assets
        @assetsView     = new AssetHost.Models.AssetDropView collection: @myassets
        @urlInput       = new ChooserUI.URLInput(chooserUI: @)

        @assetsView.bind 'click', (asset) =>
            new ChooserUI.EditModal model:asset
        
        @assetsView.bind 'remove', (asset) => 
            @myassets.remove(asset)
        
        # connect to our AssetBrowser instance, if one is given
        if @browser
            @browser.assets.bind "selected", (asset) => 
                @myassets.add(asset)
                new ChooserUI.EditModal model:asset
                
            @browser.assets.bind "admin", (asset) => 
                window.open("#{AssetHost.PATH_PREFIX}/a/assets/#{asset.get('id')}")
                    
        # set up collection to manage uploads and convert to assets
        @uploads = new AssetHost.Models.QueuedFiles null, urlRoot:@options.uploadPath
        @uploads.bind "uploaded", (f) =>
            # add this to our selected assets
            @myassets.add(f.get('ASSET'))

            # also add it to our browser, just for fun
            @browser?.assets?.add f.get('ASSET')

            # finally, remove the asset from our collection of uploads
            @uploads.remove(f)

        @uploadsView = new AssetHost.Models.QueuedFilesView collection:@uploads
        
        # manage the msg that shows when we have no assets or uploads
        @myassets.bind "all",   => @_manageEmptyMsg()
        @uploads.bind "all",    => @_manageEmptyMsg()
        
        # manage the upload all button
        @uploadAll = new ChooserUI.UploadAllButton collection:@uploads

        @drop.append(@assetsView.el, @uploadsView.el)
        @drop.after(@urlInput.render()) # Below all the buttons
        
        # manage button that pops up after uploads
        if @options.afterUploadURL and @options.afterUploadText
            @afterUpload = new ChooserUI.AfterUploadButton 
                collection: @uploads
                text:       @options.afterUploadText
                url:        @options.afterUploadURL
                
            @drop.after @afterUpload.el
        
        @drop.after(@uploadAll.el)


        # should we add a Save and Close button to the display?
        if @options.saveButton
            @saveAndClose = new AssetHost.Models.SaveAndCloseView collection: @myassets
            @saveAndClose.bind 'saveAndClose', (json) => @trigger 'saveAndClose', json
            @drop.after @saveAndClose.el
            
        # attach drag-n-drop listeners to my_assets
        @drop.bind "dragenter", (evt) => @_dropDragEnter evt
        @drop.bind "dragover",  (evt) => @_dropDragOver evt
        @drop.bind "drop",      (evt) => @_dropDrop evt
            
    #----------
    
    _manageEmptyMsg: ->
        if @myassets.length + @uploads.length > 0
            # turn empty msg off
            $(@emptyMsg).slideUp()
        else
            # turn empty msg on
            $(@emptyMsg).slideDown()
    
    #----------
    
    selectAssets: (assets) ->
        _(assets).each (obj) => 
            asset = @myassets.get(obj.id)

            if !asset
                asset = new AssetHost.Models.Asset(obj)
                asset.fetch success:(a)=>
                    a.set caption:obj.caption
                    
                    if obj.ORDER
                        a.set ORDER:obj.ORDER 
                        
                    @myassets.add(a)
                    
        @myassets.sort()
    
    #----------
    
    _dropDragEnter: (evt) ->
        evt = evt.originalEvent
        evt.stopPropagation()
        evt.preventDefault()
        false
    
    _dropDragOver: (evt) ->
        evt = evt.originalEvent
        evt.stopPropagation()
        evt.preventDefault()
        false
        
    #----------
    
    # When we receive a drop, we need to test whether it is an asset (or can
    # be made into an asset), and if so add it to our display.  
    _dropDrop: (evt) ->
        evt = evt.originalEvent
        
        evt.stopPropagation()
        evt.preventDefault()
        
        # first thing we need to test is whether we have a limit on uploads
        if @options.limit && @uploads.length >= @options.limit
            # we're at our limit...  shake our UI element and then do nothing
            $(@drop).effect "shake", {times: 3}, 100
            return false
            
        # if we get here, we're allowed to take an upload
        if evt.dataTransfer.files.length > 0
            # drop is file(s)... stage for uploader
            for f in evt.dataTransfer.files
                @uploads.add name: f.name, size: f.size, file: f

        else
            # drop is a URL. Pass it to AssetHost API and see what happens
            uri = evt.dataTransfer.getData 'text/uri-list'
            @importUri uri,
                beforeSend: _.bind @importSetup, this
                success: _.bind @importSuccess, this
                error: _.bind @importError, this
                complete: _.bind @importComplete, this
        
        false

    importSetup: (jqXHR, settings) ->
        $('.importNotification').hide()
        $(@assetsView.el).spin()

    importSuccess: (data, textStatus, jqXHR) ->
        # We might get a success response even if the asset wasn't imported
        if data.id
            $('#importSuccess').html('Successfully imported.')
            $('#importSuccess').show()
            @myassets.add data
        else
            $('#importError').html("This URL couldn't be imported.")
            $('#importError').show()

    importError: (jqXHR, textStatus, errorThrown) ->
        $('#importError').html("This URL couldn't be imported. (#{errorThrown})")
        $('#importError').show()
    
    importComplete: (jqXHR, status) ->
        $(@assetsView.el).spin(false)

    #----------

    importUri: (uri, callbacks={}) ->
        $.ajax "#{AssetHost.PATH_PREFIX}/api/as_asset", 
            _.extend
                data: url: uri,
                callbacks

    #----------



    class @URLInput extends Backbone.View
        template: JST["asset_host_core/templates/url_input"]
        className: "ah_chooser_url_input"
        events:
            'click a.add': "addToChooser"

        initialize: (attributes={}) ->
            @chooserUI  = attributes['chooserUI']

        addToChooser: (event) ->
            event.preventDefault()
            event.stopPropagation()

            input = $(event.target).siblings('input')
            uri   = input.val()
            
            @chooserUI.importUri uri,
                beforeSend: _.bind @importSetup, this
                success: _.bind @importSuccess, this
                error: _.bind @importError, this
                complete: _.bind @importComplete, this

        importSetup: (jqXHR, settings) ->
            $('.importNotification').hide()
            $(@el).spin('small')

        importSuccess: (data, textStatus, jqXHR) ->
            # We might get a success response even if the asset wasn't imported
            if data.id
                $('#importSuccess').html('Successfully imported.')
                $('#importSuccess').show()
                $('input', $(@el)).val('')
                @chooserUI.myassets.add data
            else
                $('#importError').html("This URL couldn't be imported.")
                $('#importError').show()

        importError: (jqXHR, textStatus, errorThrown) ->
            $('#importError').html("This URL couldn't be imported. (#{errorThrown})")
            $('#importError').show()
        
        importComplete: (jqXHR, status) ->
            $(@el).spin(false)

        # Must return $el
        render: ->
            $(@el).html @template()

    #----------



    
    class @EditModal extends Backbone.View
        template: JST["asset_host_core/templates/edit_modal"]
        className: "ah_asset_edit modal"
        events:
            'click button.save': '_save'
            'click button.admin': '_admin'
        
        #----------
        
        initialize: (options) ->
            # stash model attributes for later comparison
            @original = 
                title: @model.get("title")
                owner: @model.get("owner")
                notes: @model.get("notes")
                
            $(@render().el).modal()
                            
            # bind model to form
            Backbone.ModelBinding.bind(this)
            
            # attach listener for metadata changes
            @model.bind "change", =>
                if _(@original).any((v,k) => v != @model.get(k))
                    @meta_dirty = true
                    @$(".meta_dirty").show()
                else 
                    @meta_dirty = false
                    @$(".meta_dirty").hide()
            
        #----------
            
        close: ->
            Backbone.ModelBinding.unbind(this)
            $(@el).modal('hide')
        
        #----------
        
        _save: -> 
            # see whether we should save anything back to the server
            if @meta_dirty || @$("#save_caption_check")[0].checked
                @model.clone().fetch success:(m)=>
                    # set title,owner,notes
                    attr = title:@model.get("title"),owner:@model.get("owner"),notes:@model.get("notes")                        
                
                    if @$("#save_caption_check")[0].checked
                        attr.caption = @model.get("caption")
                    
                    m.save(attr)
                    @close()
                    
            else
                @close()
        
        #----------
        
        _admin: -> 
            window.open("#{AssetHost.PATH_PREFIX}/a/assets/#{@model.get('id')}") 
        
        #----------    
        
        render: ->
            $(@el).html @template(@model.toJSON())
            
            # set metadata state
            @$(".meta_dirty").hide()
            
            # set default state for caption save checkbox
            if _.isEmpty(@model.get("caption"))
                @$("#save_caption_check")[0].checked = true
            
            @
    
    #----------
    
    class @AfterUploadButton extends Backbone.View
        template: JST['asset_host_core/templates/after_upload_button']
        events:
            'click a': '_clicked'
            
        initialize: (options) ->
            @text   = options.text
            @url    = options.url
            @ids    = []

            @collection.bind "uploaded", (f) => 
                @ids.push f.get('ASSET').id
                @render()
        
        _clicked: (event) ->
            event.preventDefault()
            event.stopPropagation()
            window.location = _.template @url.replace(/{{([^}]+)}}/,"<%= $1 %>"), ids:@ids.join(",") 
            
        render: ->
            if @ids
                $(@el).html @template(text: @text)


    #----------
    

    class @UploadAllButton extends Backbone.View
        template: JST['asset_host_core/templates/upload_all_button']
        events: 
            'click button': 'uploadAll'
            
        initialize: ->
            @collection.bind "all", => @render()

        uploadAll: -> 
            @collection.each (f) -> 
                f.upload() if !f.xhr
                    

        render: ->
            staged = @collection.reduce( 
                (i,f) -> if f.xhr then i else i+1
            , 0)
            
            $(@el).html if staged > 1 then @template(count: staged) else ''
                
            @
