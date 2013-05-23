class AssetHost.Client.VimeoVideo
    template: JST['asset_host_core/clients/templates/vimeo_embed']
    
    constructor: (el, options={}) ->
        @el   = $(el)

        # get videoid from data-ah-videoid attribute
        @videoid = @el.attr("data-ah-videoid")
        
        $(document).ready =>
            @launch()
        
    #----------
    
    launch: ->
        # render template
        @html = @template(videoid: @videoid)
        @swap()

    swap: ->
        @el.replaceWith @html
