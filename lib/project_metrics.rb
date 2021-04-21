require 'byebug'
require 'ap'
require 'date'
require 'active_support'
require 'active_support/core_ext'
require 'csv'

class ProjectMetrics
  attr_reader :issue_details
  attr_reader :id_to_title

  def initialize(issue_details, id_to_title)
    @issue_details = issue_details
    @id_to_title = id_to_title
  end

  def cycletime
    filename = Config::OUTPUT_FILENAME
    puts "Generating metrics..."
    num_rows = 0

    CSV.open(filename, 'w+') do |csv|
      csv << ['Issue ID', 'Link', 'Title', 'Analysis', 'Ready to Work', 'In Progress', 'Code Review', 'QA', 'PO', 'Done', 'Assignee', 'Status', 'Days in Work', 'Tech Debt', 'Parent ID', 'Parent Name', 'Target Version', 'Tracker']
      issue_details.compact.each do |issue|
        cycle_time = CycleTime.parse issue
        next if (Config::ISSUE_OUTLIERS.include? cycle_time[:id]) ||
                (Config::TRACKERS_TO_SKIP.include? cycle_time[:tracker])
        next unless Config::CURRENT_TARGET_VERSION_IDS.include? cycle_time[:target_version_id]
        csv << [cycle_time[:id],
                cycle_time[:link], cycle_time[:subject],
                cycle_time[:analysis], cycle_time[:ready_to_work],
                cycle_time[:in_progress], cycle_time[:test],
                cycle_time[:resolved], cycle_time[:feedback],
                cycle_time[:done], cycle_time[:assignee],
                cycle_time[:status], calculate_days_in_work(cycle_time),
                is_tech_debt(cycle_time),
                cycle_time[:parent_id], id_to_title[cycle_time[:parent_id]],
                cycle_time[:target_version_name],
                cycle_time[:tracker]
              ]
        num_rows += 1
      end
    end
    puts "Wrote #{num_rows} issues to #{filename}"
  end

  def calculate_days_in_work(row)
    start_date = row[:in_progress] || row[:test] || row[:resolved] || row[:feedback]
    done_date = row[:done]
    (start_date.nil? || done_date.nil?) ? nil : (DateTime.parse(done_date) - DateTime.parse(start_date)).to_f.round(1)
  end

  def is_tech_debt(row)
    regex = Regexp.new(/tech(?:nical)*\s*debt/i)
    tech_debt_in_title = regex.match(row[:subject])
    tech_debt_in_desc = regex.match(row[:description])
    tech_debt_in_title || tech_debt_in_desc ? 'Yes' : 'No'
  end

  def kickbacks
    filename = 'kickbacks.csv'
    puts "Generating kickbacks and writing to #{filename}"

    all_kickbacks = issue_details.map { |issue| KickbackParser.parse issue }.flatten

    start_time = DateTime.parse(2019, 10,26)
    timeline = (start_time..Time.now).to_a.select { |k| k.wday == 1 }
    timeline_map = timeline.map { |d| { d => 0 } }

    all_kickbacks.each do |kickback|

    end

    total_kickbacks.each do |kickback|
      kicked_on = DateTime.parse(kickback[:kicked_on]).strftime('%m/%d/%Y')
      kickbacks_by_day[kicked_on] = 0 unless kickbacks_by_day.key? kickback[:kicked_on]
      kickbacks_by_day[kicked_on] += 1
    end

    CSV.open(filename, 'w+') do |csv|
      csv << ['Kickback On', 'Kickback Count']

      timeline_map.keys.each do |date|
        csv << [date, timeline_map[date]]
      end
    end
  end
end
