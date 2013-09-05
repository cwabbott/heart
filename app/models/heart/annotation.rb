module Heart
  class Annotation < Heart::Application
    attr_accessible :fulldate, :note, :dashboard_id
    validate :validate_note

    def validate_note
      self.note = self.note.to_s.gsub("\n\r","<br />").gsub("\r", "").gsub("\n", "<br />")
    end

    def self.visible(args)
      from = args[:from].to_date
      to = args[:to].to_date
      dashboard_id = args[:dashboard_id]
      annotations = []
      annotations.push(Annotation.where(:fulldate => from..to).where(:dashboard_id => [nil, dashboard_id]).order("fulldate ASC").all)
    end
    
  end
end
