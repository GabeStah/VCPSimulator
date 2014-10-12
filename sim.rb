class Sim

  def initialize(args = {})
    self.roster ||= args[:roster]
    self.roster = self.roster.sort do |a,b|
      b[:vcp] <=> a[:vcp]
    end
    @attendance = args[:attendance] || 95.32
    @debug = args[:debug] || true
    @player_0_attendance = args[:player_0_attendance] || @attendance
    @raid_size = args[:raid_size] || 20
    @roster_size = @roster.size || 25
  end

  def absentees
    self.roster.count{ |a| a[:status] == :absent }
  end

  def attendance
    @attendance
  end

  def attendance=(attendance)
    @attendance = attendance
  end

  def attendees
    self.roster.count{ |a| a[:status] == :attended }
  end

  def attendees=(attendees)
    @attendees = attendees
  end

  def attendance_loss
    (self.roster.size - self.attendees) * -1 / self.attendees.to_f
  end

  def attended?(attendance = nil)
    attendance ||= @attendance
    num = range(0, 100)
    return false if num > attendance
    true
  end

  def calculate_attendance
    self.attendance_loss
  end

  def create_raid
    present_attendees = 0
    # Loop through roster
    self.roster.each do |actor|
      if actor[:name] == 'player_0'
        is_present = attended?(self.player_0_attendance)
      else
        is_present = attended?
      end
      if is_present
        # If present_attendees < raid_size, player attended raid
        if present_attendees < raid_size
          present_attendees += 1 #increment
          # Charge attendance
          actor[:status] = :attended
        else # Else, player sat out
          actor[:status] = :sat
        end
      else
        # Player was absent
        actor[:status] = :absent
      end
    end

    # calculate attendance loss
    attendance_loss = self.attendance_loss

    # Delinquency offset
    delinquency_offset = (self.absentees / (self.roster.size - 1)) * -1 * 2
    # Alter VCP
    self.roster.each do |actor|
      case actor[:status]
        when :attended
          actor[:vcp] += attendance_loss + delinquency_offset
        when :sat
          actor[:vcp] += 1.0 + delinquency_offset
        when :absent
          actor[:vcp] += -1.0
      end
    end
  end

  def member(name)
    self.roster.each do |actor|
      return actor if actor[:name] == name
    end
  end

  def player_0_attendance
    @player_0_attendance
  end

  def player_0_attendance=(player_0_attendance)
    @player_0_attendance = player_0_attendance
  end

  def raid_size
    @raid_size
  end

  def raid_size=(raid_size)
    @raid_size = raid_size
  end

  def roster
    @roster
  end

  def roster=(roster)
    @roster = roster
  end

  def sittees
    self.roster.count{ |a| a[:status] == :sat }
  end

  private

  def range(min, max)
    rand * (max-min) + min
  end
end