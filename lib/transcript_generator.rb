class TranscriptGenerator

  attr_accessor :cv_path, :identifier

  TRANSCRIPT_PATH = "#{Rails.root}/xml_files/ivl_policies_transcript_files/"
  # TRANSCRIPT_PATH = "#{Rails.root}/xml_files/shop_family_transcript_files/"

  def initialize(market = 'individual')
    @identifier = 'hbx_id'
    @market = market
    my_logger
  end

  def my_logger
    @my_logger ||= Logger.new("#{Rails.root}/log/transcripts.log")
  end

  def execute
    create_directory(TRANSCRIPT_PATH)

    @count  = 0
    Dir.glob("#{Rails.root}/xml_files/ivl_policies_sample_xmls/*.xml").each do |file_path|
      begin
        @count += 1

        individual_parser = Parsers::Xml::Cv::Importers::EnrollmentParser.new(File.read(file_path))
        # individual_parser = Parsers::Xml::Cv::Importers::FamilyParser.new(File.read(file_path))

        build_transcript(individual_parser.get_enrollment_object)

      rescue Exception  => e
        my_logger.info("failed to process #{file_path}---#{e.to_s}")
      end
    end
  end

  def build_transcript(external_obj)
    transcript = Transcripts::EnrollmentTranscript.new
    transcript.shop = false
    transcript.find_or_build(external_obj)

    File.open("#{TRANSCRIPT_PATH}/#{@count}_#{transcript.transcript[:identifier]}_#{Time.now.to_i}.bin", 'wb') do |file|
      file.write Marshal.dump(transcript.transcript)
    end
  end

  def display_enrollment_transcripts
    count  = 0

    CSV.open("#{@market}_enrollment_change_sets.csv", "w") do |csv|
      if @market == 'individual'
        csv << ['Enrollment HBX ID', 'Subscriber HBX ID','SSN', 'Last Name', 'First Name', 'HIOS_ID:PlanName','Effective On', 'AASM State', 'Terminated On', 'Action', 'Section:Attribute', 'Value']
      else
        csv << ['Enrollment HBX ID', 'Subscriber HBX ID','SSN', 'Last Name', 'First Name', 'HIOS_ID:PlanName','Effective On', 'AASM State', 'Terminated On', 'Employer FEIN', 'Employer Legalname', 'Action', 'Section:Attribute', 'Value']
      end

      Dir.glob("#{TRANSCRIPT_PATH}/*.bin").each do |file_path|
        begin
          count += 1
          rows = Transcripts::ComparisonResult.new(Marshal.load(File.open(file_path))).enrollment_csv_row
          next unless rows.present?

          first_row = rows[0]
          rows.reject!{|row| row[9] == 'update' && row[11].blank?}

          # rows.reject!{|row| row[11] == 'update' && row[13].blank?}

          if rows.empty?
            # csv << (first_row[0..10] + ['match', 'match:enrollment'])
            csv << (first_row[0..8] + ['match', 'match:enrollment'])
          else
            rows.each{|row| csv << row}
          end

          if count % 100 == 0
            puts "processed #{count}"
          end
        rescue Exception => e
          puts "Failed.....#{file_path}"
        end
      end
    end
  end


  def display_family_transcripts
    count  = 0

    CSV.open('family_change_sets.csv', "w") do |csv|
      csv << ['Subscriber HBX ID', 'SSN', 'Last Name', 'First Name', 'Action', 'Section:Attribute', 'Value']

      Dir.glob("#{TRANSCRIPT_PATH}/*.bin").each do |file_path|
        begin
          count += 1
          rows = Transcripts::ComparisonResult.new(Marshal.load(File.open(file_path))).family_csv_row
          next unless rows.present?

          first_row = rows[0]
          rows.reject!{|row| row[4] == 'update' && row[6].blank?}

          if rows.empty?
            csv << (first_row[0..3] + ['match', 'match:family'])
          else
            rows.each{|row| csv << row}
          end

          if count % 100 == 0
            puts "processed #{count}"
          end
        rescue Exception => e
          puts "Failed.....#{file_path}"
        end
      end
    end
  end

  def display_transcripts
    count  = 0

    CSV.open('person_change_sets.csv', "w") do |csv|
      csv << ['HBX ID', 'SSN', 'Last Name', 'First Name', 'Action', 'Section:Attribute', 'Value']

      Dir.glob("#{Rails.root}/transcript_files/*.bin").each do |file_path|
        begin
          count += 1
          rows = Transcripts::ComparisonResult.new(Marshal.load(File.open(file_path))).csv_row
          next unless rows.present?

          first_row = rows[0]
          rows.reject!{|row| row[4] == 'update' && row[6].blank?}

          if rows.empty?
            csv << (first_row[0..3] + ['match', 'match:ssn'])
          else
            rows.each{|row| csv << row}
          end

          if count % 100 == 0
            puts "processed #{count}"
          end
        rescue Exception => e
          puts "Failed.....#{file_path}"
        end
      end
    end
  end

  private

  def create_directory(path)
    if Dir.exists?(path)
      FileUtils.rm_rf(path)
    end
    Dir.mkdir path
  end
end
