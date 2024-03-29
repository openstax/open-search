module Sqs
  def self.create_test_queue(name: 'test-open-search')
    response = client.create_queue(queue_name: name)
    response.queue_url
  end

  def self.delete_test_queue(queue_url)
    return if queue_url.nil?

    client.delete_queue(queue_url: queue_url)
  end

  def self.client
    @client ||= Aws::SQS::Client.new(region: ENV.fetch('REGION'))
  end
end
