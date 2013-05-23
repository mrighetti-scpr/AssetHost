#= require ./assethost
#= require jquery.livequery
#= require underscore.min
#= require ./slideshow

#= require spin.jquery
#= require spin.min

#= require_self
#= require_directory ./clients/templates
#= require_directory ./clients

class AssetHost.Client
    DefaultOptions:
        attr: "data-assethost"
    
    constructor: (options={}) ->
        @options = _.defaults options, @DefaultOptions
        @clients = []
        
        clients = @clients

        $ =>
            ahAttr = @options.attr
            
            # find all assethost elements and look for rich functionality
            $("img[#{@options.attr}]").livequery ->
                rich = $(this).attr ahAttr
                
                if Client[rich]
                    clients.push new Client[rich](this)
