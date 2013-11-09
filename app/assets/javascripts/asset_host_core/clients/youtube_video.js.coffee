class AssetHost.Client.YoutubeVideo
    template: JST['asset_host_core/clients/templates/youtube_embed']

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
