Scribd-CarrierWave
==================

Integrates [CarrierWave](https://github.com/jnicklas/carrierwave) with [Scribd](http://scribd.com/). This plugin was heavily influenced by [Scribd_fu](https://github.com/ProtectedMethod/scribd_fu).

[![Build Status](https://secure.travis-ci.org/aubreyrhodes/scribd-carrierwave.png)](http://travis-ci.org/aubreyrhodes/scribd-carrierwave.png)

Install
-------

````gem install scribd-carrierwave````

With bundler:

````gem 'scribd-carrierwave'````

Configure
---------
1. Sign up for a Scribd API key [here](http://www.scribd.com/developers/signup_api)

2. The following configuration settings need to be made (e.g. in an initializer):

    ```ruby
    ScribdCarrierWave.config.key = {{Scribd API Key}}
    ScribdCarrierWave.config.secret = {{Scribd Secret Key}}
    ScribdCarrierWave.config.username = {{Scribd Username}}
    ScribdCarrierWave.config.password = {{Scribd Password}}
    ```
3. In the CarrierWave uploader you wish you use with Scribd, add the line ````has_ipaper````
4. For each attribute the uploader is mounted as, add the following attributes to the model. For instance, if the uploader is mounted as :attachement add
    
    ```ruby
    t.integer :attachment_ipaper_id
    t.string  :attachment_ipaper_access_key
    ```
    
Scribd-CarrierWave will now automatically upload new attachments to Scribd as a private document, and save the id and access_key on the model.

Viewing A Document
------------------
Just add ````<%= attachment.display_ipaper %>```` into your view.

To display multiple documents on the same page, you need to pass in a unique id for each one:

````<%= attachment.display_ipaper({id: '_attachement1'}) %>````

To pass in params to the Scribd javascript options (listed [here](http://www.scribd.com/developers/javascript_api#parameters))

````<%= attachment.display_ipaper({height: 700, width: 600}) %>````

To get the link to the fullscreen document:

````<%= attachment.fullscreen_url %>````