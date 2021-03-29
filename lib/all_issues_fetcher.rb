require 'net/http'
require 'uri'
require 'json'
require 'byebug'

class AllIssuesFetcher
  def fetch
    all_issues = []

    loop do
      response = all_issues_request all_issues.count
      raise 'Request was a failure' unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      all_issues += data['issues']

      break if all_issues.count == data['total_count'].to_i
    end

    all_issues.map { |x| x['id'] }
  end

  private

  def all_issues_request(offset)
    header = {
      'Content-Type': 'application/json',
      'X-Redmine-API-Key': Config.api_key
    }
    uri = all_issues_uri offset
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri, header)

    http.request(request)
  end

  def all_issues_uri(offset)
    uri = URI("#{Config.base_url}/issues.json")
    params = {
      project_id: Config::PROJECT_ID,
      fixed_version_id: Config::ALL_TARGET_VERSION_IDS.join('|'),
      limit: 100,
      status_id: '*',
      offset: offset
    }
    uri.query = URI.encode_www_form(params)
    uri
  end
end
