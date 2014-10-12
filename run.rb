require './sim'

$output = File.open('results.txt', 'w')

def calculate_starting_points(args = {})
  seed = args[:seed] || 1
  players = args[:players] || 10
  increment = args[:increment] || 0.1
  if (players % 2) == 0 # even
    (increment * players / 2 - increment / 2 - (seed - 1) * increment).round(4)
  else # odd
    (increment * (players - 1) / 2 - (seed - 1) * increment).round(4)
  end
end

def print(line)
  $output.puts line
  puts line
end

def run_simulation(args = {})
  attendance = args[:attendance] || 95.32
  output = args[:output]
  raid_size = args[:raid_size] || 20
  roster_size = args[:roster_size] || 24
  simulation_count = args[:simulation_count] || 10
  iterations = args[:iterations] || 10000
  player_0_attendance = args[:player_0_attendance] || 95.32
  roster = []
  roster_size.times do |count|
    roster << {
      name: "player_#{count}",
      vcp: calculate_starting_points(seed: count+1, players: roster_size, increment: 0.25)
    }
  end
  settings = "Assumed Average Attendance: #{attendance}%, Raid Size: #{raid_size}, Roster Size: #{roster_size}, Special Member Attendance: #{'%.2f' % player_0_attendance}%"
  print '\\' * settings.length
  print"#{simulation_count} simulations @ #{iterations.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} iterations each."
  print settings
  print '/' * settings.length
  simulation_count.times do
    absentees = 0
    attendees = 0
    failures = 0
    successes = 0
    player_0_attended = 0
    others_attended = 0
    iterations.times {
      sim = Sim.new(attendance: attendance, raid_size: raid_size, roster_size: roster_size, roster: roster, player_0_attendance: player_0_attendance)
      sim.create_raid
      player = sim.member('player_0')
      others_attended += sim.attendees
      if player[:status] == :attended
        player_0_attended += 1
        others_attended -= 1 # remove player_0 from others total
      end
      sim.attendees < sim.raid_size ? failures += 1 : successes += 1
      absentees += sim.absentees
      attendees += sim.attendees + sim.sittees
      roster = sim.roster
    }
    print "#{'%.3f' % (attendees.to_f / (attendees + absentees) * 100)}% attendance with #{successes.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} full & #{failures.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} partial raids [#{'%.3f' % (successes / iterations.to_f * 100)}%] or 1 in every ~#{successes / failures} raids missed."
    print "Special_Member with #{'%.2f' % player_0_attendance}% attendance raided #{player_0_attended.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} times [#{'%.3f' % ((player_0_attended / iterations.to_f) * 100)}%]"
    print "Average_Member with #{'%.2f' % attendance}% attendance raided #{(others_attended / (roster_size - 1)).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} times [#{'%.3f' % ((others_attended / (roster_size - 1) / iterations.to_f) * 100)}%]"
    print '-' * settings.length
  end
  print ""
end

roster_sizes = [
  22,
  23,
  24,
  25
]
player_0_attendances = [
  90,
  95.32,
  100
]
roster_sizes.each do |roster_size|
  player_0_attendances.each do |player_0_attendance|
    run_simulation(output: $output, iterations: 100000, player_0_attendance: player_0_attendance, roster_size: roster_size, simulation_count: 5)
  end
end
$output.close