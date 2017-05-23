class AssetHost.Models
    constructor: ->

    class @Asset extends Backbone.Model
        urlRoot: "http://#{AssetHost.SERVER}/api/assets/"

        modal: ->
            @_modal ?= new AssetHost.Models.AssetModalView(model: @)

        #----------

        url: ->
            url = if @isNew() then @urlRoot else @urlRoot + encodeURIComponent(@id)

            if AssetHost.TOKEN
                url = url + "?" + $.param({auth_token:AssetHost.TOKEN})

            url

        #----------

        chopCaption: (count=100) ->
            chopped = @get('caption')

            if chopped and chopped.length > count
                regstr = "^(.{#{count}}\\w*)\\W"
                chopped = chopped.match(new RegExp(regstr))

                if chopped
                    chopped = "#{chopped[1]}..."
                else
                    chopped = @get('caption')

            chopped

    #----------

    class @Assets extends Backbone.Collection
        baseUrl: "/api/assets",
        model: Models.Asset

        # If we have an ORDER attribute, sort by that.  Otherwise, sort by just
        # the asset ID.
        comparator: (asset) ->
            asset.get("ORDER") || -Number(asset.get("id"))

        #----------


    class @PaginatedAssets extends @Assets
        initialize: (data,opts)->
            _.bindAll(this, 'parse', 'url')

            @_page          = 1
            @_query         = ''
            @per_page       = 24
            @total_entries  = 0

            @

        parse: (resp, xhr) ->
            @next_page      = xhr.getResponseHeader('X-Next-Page')
            @total_entries  = xhr.getResponseHeader('X-Total-Entries')

            # inject ORDER into our responses
            a.ORDER = idx for a,idx in resp

            resp

        url: ->
            @baseUrl + "?" + $.param(page: @_page, q: @_query)

        query: (q=@_query) ->
            @_query = q if q?
            @_query

        page: (p=null) ->
            @_page = Number(p) if p? && p != ''
            @_page

    #----------

    class @AssetDropAssetView extends Backbone.View
        tagName: 'li'
        template: JST['templates/asset_drop_asset']
        events:
            'click button.delete': "_remove"
            'click': '_click'

        #----------

        initialize: ->
            @del_confirm = false
            @del_timeout = null

            @drop = @options.drop
            @model.bind "change", => @render()
            @render()

        #----------

        _remove: (evt) ->
            if @del_confirm
                # delete
                clearTimeout @del_timeout

                # remove our model...
                _.defer => @drop.trigger 'remove', @model
            else
                target = $(evt.target)
                target.text "Really Delete?"
                @del_confirm = true

                # set a reset timeout
                @del_timeout = setTimeout =>
                    target.text "x"
                    @del_confirm = false
                    @del_timeout = null
                , 2000

            false

        #----------

        _click: (evt) ->
            if not $(evt.currentTarget).hasClass("delete")
                @drop.trigger 'click', @model

        #----------

        render: ->
            $(@el).html @template
                asset: @model.toJSON()
                chop: @model.chopCaption()

            $(@el).attr "data-asset-id", @model.get("id")
            @

    #----------

    class @AssetDropView extends Backbone.View
        tagName: "ul"
        className: "assets"

        initialize: ->
            @_views = {}

            @collection.bind 'add', (f) =>
                @collection.sort()

            @collection.bind 'remove', (f) =>
                @collection.sort()

            @collection.bind 'reset', (f) =>
                _(@_views).each (av) => $(av.el).detach()
                @_views = {}
                @render()

        #----------

        render: ->
            # set up views for each collection member
            @collection.each (f) =>
                # create a view unless one exists
                @_views[f.cid] ?= new Models.AssetDropAssetView(model: f, drop: @)

            # make sure all of our view elements are added
            $(@el).append( _(@_views).map (v) -> v.el )

            $(@el).sortable
                update: (evt,ui) =>
                    _(@el.children).each (li,idx) =>
                        id = $(li).attr('data-asset-id')
                        @collection.get(id).attributes.ORDER = idx
                    @collection.sort()

            @

    #----------

    class @AssetSearchView extends Backbone.View
        className: "search_box"
        template: JST['templates/asset_search']
        events:
            'click button': 'search',
            'keypress input:text': '_keypress'

        initialize: ->
            @collection.bind('all', => @render() )

        _keypress: (e) ->
            @search() if e.which == 13

        search: ->
            query = $(@el).find("input")[0].value
            @trigger "search", query

        render: ->
            $(@el).html @template(query: @collection.query())
            @

    #----------

    class @AssetBrowserAssetView extends Backbone.View
        tagName: "li"
        template: JST['templates/browser_asset']
        tipTemplate: JST['templates/browser_asset_tip']

        initialize: ->
            @id = "ab_#{@model.get('id')}"
            $(@el).attr("data-asset-url",@model.get('url'))
            
            @render()

            $(@el).find('button')[0].addEventListener "click", (evt) =>
                @trigger "click", @model
                true

            # add tooltip
            $(@el).tooltip
                title: @tipTemplate(@model.toJSON())
                html: true

            @model.bind "change", => @render()

        render: ->
            $(@el).html @template(@model.toJSON())
            $(@el).attr "draggable", true
            @

    #----------

    class @AssetBrowserView extends Backbone.View
        tagName: "ul"

        initialize: ->
            @_views = {}

            @container = $("#content_right")

            @collection.bind "reset", =>
                _(@_views).each (a) => $(a.el).detach()
                @_views = {}
                @render()

        pages: ->
            @_pages ?= (new AssetHost.Models.PaginationLinks(@collection)).render()

        loading: ->
            $(@el).css(opacity: ".1")
            @container.spin()

        doneLoading: ->
            $(@el).css(opacity: "1")
            @container.spin(false)

        render: ->
            # set up views for each collection member
            @collection.each (a) =>
                # create a view unless one exists
                @_views[a.cid] ?= new AssetHost.Models.AssetBrowserAssetView(model: a)
                @_views[a.cid].bind "click", (a) => @trigger "click", a

            # make sure all of our view elements are added
            $(@el).append( _(@_views).map (v) -> v.el )

            # clear loading status
            @doneLoading()
            @

    #----------

    class @AssetModalView extends Backbone.View
        className: "modal"
        events:
            'click a.select': '_select'
            'click a.admin': '_admin'
            'click a.close': 'close'

        template: JST['templates/asset_modal']

        open: (options) ->
            @options = options || {}
            $(@render().el).modal()

            $(@render().el).on "hide", => @options.close?()

        close: ->
            $(@el).modal('hide')

        _select: ->
            @close()
            @model.trigger('selected',@model)

        _admin: ->
            @close()
            @model.trigger('admin',@model)

        render: ->
            $(@el).html @template
                asset: @model.toJSON()
                select: if @options.select? then @options.select else true
                admin: if @options.admin? then @options.admin else false

            @

    #----------

    class @SaveAndCloseView extends Backbone.View
        events: 'click button': 'saveAndClose'
        template: JST['templates/save_and_close_view']

        initialize: ->
            @collection.bind "all", => @render()
            @render()

        saveAndClose: ->
            # make sure collection is sorted before we return it
            @collection.sort()
            @trigger 'saveAndClose', @collection.toJSON()

        render: ->
            $(@el).html @template(count: @collection.size())
            @

    #----------

    class @PaginationLinks extends Backbone.View
        className: "pagination pagination-centered"
        template: JST['templates/pagination_links']
        linkTemplate: JST['templates/pagination_link']

        DefaultOptions:
            inner_window: 3,
            outer_window: 1,
            prev_label: "&#8592;",
            next_label: "&#8594;",
            separator: " ",
            spacer: "<li class='disabled'><a href='#'>...</a></li>"

        events: 'click li': 'clickPage'

        initialize: (@collection, options={}) ->
            @options = _.defaults options, @DefaultOptions

            @collection.bind "reset",       => @render()
            @collection.bind "add",         => @render()
            @collection.bind "change",      => @render()

        #----------

        clickPage: (evt) ->
            page = $(evt.currentTarget).attr("data-page")

            if page
                @trigger "page", page

        render: ->
            # what pages are we displaying?
            pages       = Math.floor( @collection.total_entries / @collection.per_page + 1)
            current     = @collection._page

            rendered    = {}
            links       = []

            # start with outer_window from 1
            _(_.range(1,1+@options.outer_window)).each (i) =>
                links.push @linkTemplate
                    page: i
                    current: current==i


                rendered[ i ] = true


            # now try -inner_window from current
            _(_.range(current-@options.inner_window,current)).each (i) =>
                if i > 0 && !rendered[ i ]
                    if i-1 > 0 && !rendered[i-1]
                        links.push @options.spacer

                    links.push @linkTemplate
                        page: i
                        current: false


                    rendered[ i ] = true


            # now try current
            if !rendered[ current ]
                if current-1 > 0 && !rendered[current-1]
                    links.push @options.spacer

                links.push @linkTemplate
                    page: current
                    current: true


                rendered[ current ] = true

            # now try +inner_window from current
            _(_.range(current+1,current+@options.inner_window+1)).each (i) =>
                if i < pages && !rendered[ i ]
                    if i-1 > 0 && !rendered[i-1]
                        links.push @options.spacer

                    links.push @linkTemplate
                        page: i
                        current: false


                    rendered[ i ] = true


            # and finally, -outer_window from last page
            _(_.range(pages+1-@options.outer_window,pages+1)).each (i) =>
                if i > 0 && !rendered[ i ]
                    if i-1 > 0 && !rendered[i-1]
                        links.push @options.spacer

                    links.push @linkTemplate
                        page: i
                        collection: @collection
                        current: current==i


                    rendered[ i ] = true


            $(@el).html @template
                current: current
                pages: pages
                links: links.join(@options.separator)
                options: @options


            @

    #----------

    @queuedSync: (method,model,success,error) ->
        #

    class @QueuedFile extends Backbone.Model
        sync: Models.queuedSync

        upload: ->
            return false if @xhr

            @xhr = new XMLHttpRequest

            $(@xhr.upload).bind "progress", (evt) =>
                evt = evt.originalEvent
                @set {"PERCENT": if evt.lengthComputable then Math.floor(evt.loaded/evt.total*100) else evt.loaded}

            $(@xhr.upload).bind "complete", (evt) =>
                @set {"STATUS": "pending"}

            @xhr.onreadystatechange = (req) =>
                if @xhr.readyState == 4 && @xhr.status == 200
                    @set {"STATUS": "complete"}

                    if req.responseText != "ERROR"
                        @set {"ASSET": $.parseJSON(@xhr.responseText)}
                        @trigger "uploaded", this

            @xhr.open('POST',this.collection.urlRoot, true)
            @xhr.setRequestHeader('X_FILE_NAME', @get('file').name)
            @xhr.setRequestHeader('CONTENT_TYPE', @get('file').type)
            @xhr.setRequestHeader('HTTP_X_FILE_UPLOAD','true')
            # and away we go...
            @xhr.send @get('file')
            @set {"STATUS": "uploading"}

        readableSize: ->
            return false if !@get('size')
            size = @get('size')

            units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
            i = 0;

            while size >= 1024
                size /= 1024
                ++i

            size.toFixed(1) + ' ' + units[i];

    #----------

    class @QueuedFiles extends Backbone.Collection
        model: Models.QueuedFile
        urlRoot: "/assets/upload"

        initialize: (models,options) ->
            @urlRoot = options.urlRoot

    #----------

    class @QueuedFileView extends Backbone.View
        events:
            'click button.remove': '_remove',
            'click button.upload': '_upload'

        tagName: "li"
        template: JST['templates/queued_file']

        initialize: ->
            @model.bind "change", => @render()

            @img = ''

            # try to read file on disk
            file = @model.get('file')
            if file.type.match('image.*')
                reader = new FileReader()

                reader.onload = (e) =>
                    @img = $ "<img/>", {
                        class: "thumb",
                        src: e.target.result,
                        title: file.name
                    }

                    m = /^([^,]+),(.*)$/.exec(e.target.result)
                    @exif = EXIF.readFromBinaryFile(window.atob(m[2]))

                    @render()

                reader.readAsDataURL(file)

            @render()

        _remove: (evt) ->
            @model.collection.remove(@model)

        _upload: (evt) ->
            @model.upload()

        render: ->
            $(@el).attr('class',@model.get("STATUS"))

            $(@el).html @template
                exif: @exif
                name: @model.get('name')
                size: @model.readableSize()
                STATUS: @model.get('STATUS')
                PERCENT: @model.get('PERCENT')
                xhr: if @model.xhr then true else false


            $(@el).prepend(@img) if @img
            @

    #----------

    class @QueuedFilesView extends Backbone.View
        tagName: "ul"
        className: "uploads"

        initialize: ->
            @_views = {}

            @collection.bind 'add', (f) =>
                @_views[f.cid] = new Models.QueuedFileView(model: f)
                @render()

            @collection.bind 'remove', (f) =>
                $(@_views[f.cid].el).detach()
                delete @_views[f.cid]
                @render()

            @collection.bind 'reset', (f) =>
                @_views = {}

        _reset: (f) ->
            # do we need this?

        render: ->
            # set up views for each collection member
            @collection.each (f) =>
                # create a view unless one exists
                @_views[f.cid] ?= new Models.QueuedFileView(model: f)

            # make sure all of our view elements are added
            $(@el).append( _(@_views).map (v) -> v.el )

            @
