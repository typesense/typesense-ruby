require_relative '../spec_helper'
require_relative 'shared_configuration_context'

describe Typesense::ApiCall do
  include_context 'Typesense configuration'

  shared_examples 'error handling' do |method|
    {
        400 => Typesense::Error::RequestMalformed,
        401 => Typesense::Error::RequestUnauthorized,
        404 => Typesense::Error::ObjectNotFound,
        409 => Typesense::Error::ObjectAlreadyExists,
        422 => Typesense::Error::ObjectUnprocessable,
        500 => Typesense::Error::ServerError,
        300 => Typesense::Error
    }.each do |response_code, error|
      it "throws #{error} for a #{response_code} response" do
        stub_request(:any, Typesense::ApiCall.send(:uri_for, '/')).
            to_return(status:  response_code,
                      body:    JSON.dump({ 'message' => 'Error Message' }),
                      headers: { 'Content-Type' => 'application/json' }
            )

        expect {
          subject.send(method, '')
        }.to raise_error error
      end
    end
  end

  describe '#post' do
    include_examples 'error handling', :post
  end

  describe '#get' do
    include_examples 'error handling', :get
  end

  describe '#get_unparsed_response' do
    include_examples 'error handling', :get_unparsed_response
  end

  describe '#delete' do
    include_examples 'error handling', :delete
  end
end

