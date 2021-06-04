class Config
  def self.api_key
    ENV['UNDERMINER_API_KEY']
  end

  def self.base_url
    ENV['UNDERMINER_BASE_URL']
  end

  OUTPUT_FILENAME = 'cycletimes.csv'.freeze
  PROJECT_ID = '745'.freeze
  CURRENT_TARGET_VERSION_IDS = [1207, 1228, 1271, 1334, 1456].freeze
  OLD_TARGET_VERSION_IDS = %w[1302 944 1303].freeze
  ALL_TARGET_VERSION_IDS = CURRENT_TARGET_VERSION_IDS.map(&:to_s).concat(OLD_TARGET_VERSION_IDS).freeze

  ANALYSIS_STATUS_ID = '4'.freeze
  READY_TO_WORK_STATUS_ID = '10'.freeze
  IN_PROGRESS_STATUS_ID = '3'.freeze
  TEST_STATUS_ID = '11'.freeze
  RESOLVED_STATUS_ID = '6'.freeze
  FEEDBACK_STATUS_ID = '5'.freeze
  DONE_STATUS_ID = '9'.freeze

  COLUMN_ORDER = {
    Config::ANALYSIS_STATUS_ID => 1,
    Config::READY_TO_WORK_STATUS_ID => 2,
    Config::IN_PROGRESS_STATUS_ID => 3,
    Config::TEST_STATUS_ID => 4,
    Config::RESOLVED_STATUS_ID => 5,
    Config::FEEDBACK_STATUS_ID => 6,
    Config::DONE_STATUS_ID => 7
  }.freeze

  ISSUE_OUTLIERS = [36319, 40351, 40519, 79900, 83818]
  TRACKERS_TO_SKIP = ['Epic', 'Feature', 'Support', 'Key Decision']
end
