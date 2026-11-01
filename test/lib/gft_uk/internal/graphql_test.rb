require_relative '../../../test_helper'

class GftUk::Internal::GraphqlTest < Minitest::Test
  GRAPHQL = GraphqlStubs::GRAPHQL
  QUERY = '{ __typename }'.freeze

  def test_query_posts_the_document_as_a_consumer_of_the_site
    stub_request(:post, GRAPHQL).to_return(status: 200, body: '{"data":{"__typename":"Query"}}')

    assert_equal({ '__typename' => 'Query' }, graphql.query(QUERY, a: 1))
    assert_requested :post, GRAPHQL,
                     headers: { 'Content-Type' => 'application/json', 'Client-Type' => 'consumer', 'Site-Id' => '103' },
                     body: { query: QUERY, variables: { a: 1 } }.to_json
  end

  def test_error_objects_raise
    stub_request(:post, GRAPHQL).to_return(status: 200, body: '{"data":{},"error":{"message":"No Site ID"}}')

    error = assert_raises(RuntimeError) { graphql.query(QUERY) }
    assert_equal 'Indy GraphQL error: No Site ID', error.message
  end

  def test_error_lists_raise
    stub_request(:post, GRAPHQL).to_return(status: 200, body: '{"errors":[{"message":"Bad field"}]}')

    error = assert_raises(RuntimeError) { graphql.query(QUERY) }
    assert_equal 'Indy GraphQL error: Bad field', error.message
  end

  def test_http_errors_name_the_status_but_not_the_body
    stub_request(:post, GRAPHQL).to_return(status: 500, body: 'secret')

    error = assert_raises(RuntimeError) { graphql.query(QUERY) }
    assert_equal 'Indy HTTP error 500', error.message
  end

  def test_requests_share_a_connection
    stub_request(:post, GRAPHQL).to_return(status: 200, body: '{"data":{}}')
    client = graphql

    client.query(QUERY)
    client.query(QUERY)

    assert_same client.send(:connection), client.send(:connection)
    assert_requested :post, GRAPHQL, times: 2
  end

  def test_transient_errors_are_retried
    stub_request(:post, GRAPHQL).to_raise(Errno::ECONNRESET).then.to_return(status: 200, body: '{"data":{}}')
    client = graphql

    client.stub(:sleep, nil) { client.query(QUERY) }

    assert_requested :post, GRAPHQL, times: 2
  end

  def test_transient_errors_are_raised_after_retries
    stub_request(:post, GRAPHQL).to_raise(Net::OpenTimeout)
    client = graphql

    assert_raises(Net::OpenTimeout) { client.stub(:sleep, nil) { client.query(QUERY) } }
    assert_requested :post, GRAPHQL, times: 3
  end

  private

  def graphql
    GftUk::Internal::Graphql.new(GRAPHQL, site_id: '103')
  end
end
