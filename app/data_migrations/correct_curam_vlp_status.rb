require File.join(Rails.root, "lib/mongoid_migration_task")

class CorrectCuramVlpStatus < MongoidMigrationTask
  def get_people
    Person.where('consumer_role' => {'$exists' => true},
                 'consumer_role.lawful_presence_determination.vlp_authority' => 'curam')
  end

  def update_person(person)
    begin
      person.consumer_role.lawful_presence_determination.aasm_state = "verification_successful"
      person.consumer_role.import!
      person.save!
      print "."
    rescue => e
      puts
      puts "Error for Person id: #{person.id}. Error: #{e.message}"
      puts
    end
  end

  def migrate
    people_to_fix = get_people
    puts
    puts "#{people_to_fix.count} records will be fixed."
    puts
    people_to_fix.each do |person|
      update_person(person)
    end
  end
end
