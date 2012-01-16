# DirectWave

This gem provides a simple way to direct upload big files to Amazon S3 
storage from Ruby applications and process it with cloud encoding service, 
such as zencoder.com or pandastream.com.

It works well with Rack based web applications, such as Ruby on Rails.

Inspired by [CarrierWave](https://github.com/jnicklas/carrierwave) and used in [radiant.fm](http://radiant.fm).

## Information

* RDoc documentation [available on RubyDoc.info](http://rubydoc.info/gems/DirectWave/frames)
* Source code [available on GitHub](https://github.com/radiantfm/directwave)

## Getting Help

* Please report bugs on the [issue tracker](https://github.com/radiantfm/directwave/issues).

## Installation

Install the latest stable release:

	[sudo] gem install directwave

In Rails, add it to your Gemfile:

``` ruby
gem "directwave"
```

## Getting Started

Start off by generating an uploader:

	rails generate directwave Audio

this should give you a file in:

	app/uploaders/audio_uploader.rb

Now you can customize your uploader. It
should look something like this:

``` ruby
class AudioUploader < DirectWave::Uploader::Base
end
```

Most of the time you are going to want to use DirectWave together with an ORM.
It is quite simple to mount uploaders on columns in your model, so you can
simply assign files and get going:

## ActiveRecord

Add a string column to the model you want to mount the uploader on:

``` ruby
add_column :tracks, :audio, :string
```

Open your model file and mount the uploader:

``` ruby
class Track < ActiveRecord::Base
  mount_directwave :audio, AudioUploader
end
```

Now you can cache files by assigning them to the attribute, they will
automatically be stored when the record is saved.

``` ruby
u = Track.new(:audio_from_key => params[:key])
u.save!
u.audio.url # => '/url/to/file.png'
```

## Rails

You can use different flash uploaders for multiple direct upload, 
such as [Uploadify](http://www.uploadify.com). For example in Rails with CoffeeScript and Nokogiri
generate uploader controller at first:

	rails g controller Uploads new create

and add following code:

``` ruby
class UploadsController < ApplicationController
  def new
    @uploader = Track.new.audio
  end

  def create
    xml_doc  = Nokogiri::XML(params[:xml])

    @track = Track.new(audio_from_key: xml_doc.xpath('//Key').text)
    @track.save
    
    head :ok
  end
end
```

when in `assets/javascript/uploads.js.coffe` insert:

``` html
$(document).ready ->
  uploader = $("#uploadify") 
  uploader.uploadify {
    uploader     : "path/to/swf/uploader"
    method       : "post"
    multi        : true
    auto         : true
    fileDataName : "file"
    script       : uploader.data("bucket) + ".s3.amazonaws.com"
    scriptAccess : "always"
    scriptData   : {
      "AWSAccessKeyId" : uploader.data("aws-access-key-id"),
      "key"            : uploader.data("key"),
      "acl"            : uploader.data("acl"),
      "policy"         : uploader.data("policy"),
      "signature"      : uploader.data("signature"),
      "success_action_status" : "201"
    },
    onError    : (event, id, file, error) -> console.log(error),
    onComplete : (event, id, file, response, data) -> 
      $.ajax({
        type  : 'post',
        url   : '/uploads',
        data  : { xml: response },
        cache : false
      });
  }
```   

in `views/uploads/new.html.erb`:

``` html
<%= file_field_tag "uploadify" , "data-aws-access-key-id" => @uploader.s3_access_key_id, 
                                 "data-key"       => @uploader.store_key, 
                                 "data-acl"       => @uploader.s3_acl, 
                                 "data-policy"    => @uploader.s3_policy,
                                 "data-signature" => @uploader.s3_signature,
                                 "data-bucker"    => @uploader.s3_bucket %> 
```


## Changing the directories

In order to change where uploaded files are stored, just override the `store_dir`
method:

``` ruby
class MyUploader < DirectWave::Uploader::Base
  def store_dir
    '/my/upload/directory'
  end
end
```

If you want change where files will be uploaded, override the `upload_dir`
method:

``` ruby
class MyUploader < DirectWave::Uploader::Base
  def upload_dir
    '/my/upload/directory/tmp'
  end
end
```

## Adding versions

Often you'll want to add different versions of the same file.
There is built in support for this:

``` ruby
class Audio < DirectWave::Uploader::Base
  version :aac do
    def filename
      # where @name name of version, for now "aac"
      @filename ||= [extract(:guid), [@name, extract(:basename)].join("/") << ".aac"].join("/")
    end

    def process
      # proccessing code goes here
      # always call super at the begin
      super
      
      job = Zencoder::Job.create(
        { 
          input: "s3://#{@uploader.s3_bucket}.s3.amazonaws.com/#{@uploader.versions[:original].key}", 
          outputs: [
            {
              label: "aac",
              url: "s3://#{@uploader.s3_bucket}.s3.amazonaws.com/#{@uploader.versions[:aac].key}",
              format: "aac",
              notifications: [{ url: "http://zencoderfetcher/", format: "json" }]
            } # aac
          ] # outputs
        }
      ) 
      @uploader.model.job_id = job.body["id"]
    end
  end
end
```

When this uploader is used, a version called aac is then created, which is processed with `process`. 
The uploader could be used like this:

``` ruby
uploader.url # => '/url/to/original/file.png'               
uploader.url(:original) # => '/url/to/original/file.png'               
uploader.aac.url # => '/url/to/aac/file.png'   
uploader.url(:aac) # => '/url/to/aac/file.png'   
```

You can also override `global_process` method wich called after 
all process within versions:

``` ruby
class Audio < DirectWave::Uploader::Base
  version :aac
  version :wav

  def global_process
    super
    
    job = Zencoder::Job.create(
      { 
        input: "s3://#{s3_bucket}.s3.amazonaws.com/#{versions[:original].key}", 
        outputs: [
          {
            label: "aac",
            url: "s3://#{s3_bucket}.s3.amazonaws.com/#{versions[:aac].key}",
            format: "aac",
            notifications: [{ url: "http://zencoderfetcher/", format: :json }]
          }, # aac
          {
            label: "wav",
            url: "s3://#{s3_bucket}.s3.amazonaws.com/#{versions[:wav].key}",
            format: "wav",
            notifications: [{ url: "http://zencoderfetcher/", format: :json }]
          } # wav

        ] # outputs
      }
    ) 
    model.job_id = job.body["id"]
  end
end
```

## Providing a default URL

In many cases  it might be a good idea to rovide a default url, a fallback in case 
no file has been uploaded. You can do this easily by overriding the `default_url` 
method in your uploader:

``` ruby
class Audio < DirectWave::Uploader::Base
  def default_url
    "/fallback/default.mp3"
  end
end
```

## Configuring DirectWave

DirectWave has a broad range of configuration options, which you can configure,
both globally and on a per-uploader basis:

``` ruby
DirectWave.configure do |config|
  config.s3_access_key_id     = "access_key_id"
  config.s3_secret_access_key = "secret_access_key"
  config.s3_bucket            = "bucket"
  config.s3_region            = "region"
  config.s3_access_policy     = :private # or other valid value, see amazon s3 docs
end
```
If you're using Rails, create an initializer for this:

``` ruby
config/initializers/directwave.rb
```

## License

Copyright (c) 2012 radiant.fm

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
