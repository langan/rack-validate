require 'rubygems'
require 'rack'
require 'rack-validate/response_file'
require 'rack-validate/validator'

module Rack
  
  # A rack middleware for validating HTML via w3c validator
  class Validate
    
    def initialize( app )
      @app = app
    end
        
    def call( env )
      status, headers, body = @app.call(env)
      resp = Rack::Response.new(body, status, headers)
      
      request = Rack::Request.new( env )
      if request.params['rack-validate'] == "true"
        if headers['Content-Type'] =~ /text\/html|application\/xhtml\+xml/
          body = resp.body.dup
        
          issues = Validator.validate( body )
        
          body.insert( 0, Validator.generate_report( issues ) )
        
          resp.body = ""
          resp.write(body)
        end
      end
      
      resp.to_a
    end
          
  end
end
