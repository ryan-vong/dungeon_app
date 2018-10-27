# Ryan Vong
# CS 132A - Ruby
#
# Dungeon: You need a general class that encapsulates the entire concept of the dungeon game.

# Player: The player provides the link between the dungeon and you.
# All experience of the dungeon comes through the player.

# Rooms: The rooms of the dungeon are the locations that the player can navigate
# between.  These will be linked together in many ways (doors to the north, west, south, east).

# Treasures: The treasure will be stored in certain room identified by location

# Satchel is just an array storing the treasure reference

class Dungeon
  attr_accessor :player

  def initialize(player_name)
    # create player object
    @player = Player.new(player_name)

    # an array to store Room objects
    @rooms = []

    # an array to store Treasure objects
    @treasures = []

    # an array to store treasure reference
    @satchel = []
  end

  # check if treasure is in current room
  def check_treasure
      if (treasure?)
          show_found_treasure
      else puts "No treasure in this room."
      end
  end

  # show treasure inside satchel
  def show_treasure_in_satchel
    str = "Your satchel contains:\n"
    satchel = ""
    @satchel.each_with_index do |treasure, i|
      satchel += (i+1).to_s + ". "+ treasure.to_s + "\n"
    end
    satchel = "nothing." if satchel.empty?
    puts str + satchel
  end

  # check if there's treasure in satchel
  def treasure_in_satchel?
    @treasures.each do |treasure|
      if treasure.location == :satchel
        return true
      end
    end
    return false
  end

  # check if key is in satchel
  def has_key?
    find_treasure_in_satchel(:key) != nil
  end

  # check if holy grail is in satchel
  def has_holy_grail?
    find_treasure_in_satchel(:holy_grail) != nil
  end

  # find treasure object in satchel
  def find_treasure_in_satchel(reference)
    @treasures.detect {|treasure| treasure.reference == reference && treasure.location == :satchel}
  end

  # Add treasure to satchel
  def pickup_treasure
    # find treasure in room
    treasure = find_treasure_by_location(@player.location)

    # pick up treasure by changing location to satchel
    treasure.location = :satchel

    # add treasure to array satchel
    @satchel << treasure.reference

    # print picked up treasure
    puts "You picked up " + treasure.name
  end

  # Drop treasure to current location
  def dropoff_treasure(reference)
    # find the treasure and room
    treasure = @treasures.detect {|tr| tr.reference == reference}

    # drop off by changing location to current location
    treasure.location = @player.location
    # find room where it's dropped off
    room = @rooms.detect {|rm| rm.reference == treasure.location}

    # remove treasure from satchel array
    @satchel.delete(reference)

    puts "You dropped off " + treasure.name + " " + room.description
  end

  # add treasure to each room
  def add_treasure(reference, name, location)
    @treasures << Treasure.new(reference, name, location)
  end

  # check if treasure is in current room
  def treasure?
    find_treasure_by_location(@player.location) != nil
  end

  # ask player to choose treasure to drop off
  def select_treasure
    while (true)
      print "Please enter corresponding number in satchel list to drop off or '0' to cancel: "
      input = gets.chomp.to_i
      if input == 0
        item = nil
        break
      end
      item = @satchel[input-1]
      if (item == nil || input < 1)
        puts "No item corresponding to number."
      else
        break
      end
    end

    return item
  end

  # show full description of treasure in current room
  def show_found_treasure
    puts find_treasure_by_location(@player.location).full_description
  end

  # find treasure given the reference and return Treasure object
  def find_treasure_by_location(location)
    @treasures.detect {|treasure| treasure.location == location}
  end

  # add room
  def add_room(reference, name, description, connections)
    @rooms << Room.new(reference, name, description, connections)
  end

  # Starts the game by placing player in a location (:large_cave, :small_cave, ...)
  def start(location)
    @player.location = location
    show_current_description
  end

  # Find the room where the player is and then get full_description of room
  def show_current_description
    puts find_room_in_dungeon(@player.location).full_description
  end

  # Find the room given the reference and return Room object
  def find_room_in_dungeon(reference)
    @rooms.detect {|room| room.reference == reference}
  end

  # Find the room where the player is heading based on location and direction
  def find_room_in_direction(direction)
    find_room_in_dungeon(@player.location).connections[direction]
  end

  # Go to the room based on player's location and direction
  def go(direction)
    puts "You go " + direction.to_s
    @player.location = find_room_in_direction(direction)
    show_current_description
  end

  # Ask player for input
  def select_action
    while (true)
      puts "n = Go North"
      puts "s = Go South"
      puts "e = Go East"
      puts "w = Go West"
      puts "c = Where am I?"
      puts "p = Pick up item"
      puts "d = Drop off item"
      puts "i = List items in satchel"
      puts "q = Quit game"
      print "Please select an action: "
      input = gets.chomp.downcase
      if (input != 'n' && input != 's' && input != 'e' && input != 'w' && input != 'p' && input != 'd' && input != 'i' && input != 'q' && input != 'c')
          puts "Invalid input. Only (n/s/e/w/p/d/i/q/c)"
      elsif (input == 'w') && (find_room_in_direction(:west) == nil)
          print_dashes
          print "No room in the west direction.\n\n"
      elsif (input == 'e') && (find_room_in_direction(:east) == nil)
          print_dashes
          print "No room in the east direction.\n\n"
      elsif (input == 's') && (find_room_in_direction(:south) == nil)
          print_dashes
          print "No room in the south direction.\n\n"
      elsif (input == 'n') && (find_room_in_direction(:north) == nil)
          print_dashes
          print "No room in the north direction.\n\n"
      elsif (input == 'p') && (!treasure?)
          print_dashes
          print "No treasure to pick up in this room.\n\n"
      elsif (input == 'd') && (!treasure_in_satchel?)
          print_dashes
          print "No treasure in your satchel to drop off.\n\n"
      elsif (input == 'i') && (!treasure_in_satchel?)
          print_dashes
          print "Your satchel is empty.\n\n"
      else
          break
      end
    end
    return input
  end

  # check if next room is main
  def main?
     find_room_in_direction(:north) == :main_room
  end

  # Player class
  class Player
    attr_accessor :name, :location

    def initialize(playerName)
      @name = playerName
    end
  end # end of Player

  # Room class
  class Room
    attr_accessor :reference, :name, :description, :connections

    def initialize(reference, name, description, connections)
      @reference = reference
      @name = name
      @connections = connections
      @description = description
    end

    def full_description
      @name + "\n\nYou are " + @description + "\n"
    end
  end # end of Room

  # Treasure class to create treasure object in a room
  class Treasure
    attr_accessor :reference, :name, :location

    def initialize(reference, name, location)
      @reference = reference
      @name = name
      @location = location
    end

    def full_description
      "You found the " + @name + "\n"
    end
  end # end of Treasure

end # end of Dungeon

# print 50 dashes
def print_dashes
  puts "-" * 70
end

# create the main dungeon object with the player name
my_dungeon = Dungeon.new("Ryan")

# add rooms to dungeon
my_dungeon.add_room(:large_cave, "Large Cave", "in a large cavernous cave", {:west => :small_cave, :south => :treasure_room, :north => :main_room, :east => :prison_room})
my_dungeon.add_room(:small_cave, "Small Cave", "in a small claustrophobic cave", {:east => :large_cave})
my_dungeon.add_room(:treasure_room, "Treasure Room", "in a treasure room", {:north => :large_cave})
my_dungeon.add_room(:main_room, "Main Room", "in the main room", {:south => :large_cave})
my_dungeon.add_room(:prison_room, "Prison Room", "in the prison room", {:west => :large_cave})

# add treasure to room
my_dungeon.add_treasure(:holy_grail, "holy grail", :treasure_room)
my_dungeon.add_treasure(:sword, "sword", :small_cave)
my_dungeon.add_treasure(:key, "key", :prison_room)

print_dashes
puts "Objective: Find 'Key' and 'Holy Grail' to unlock main room."
print_dashes

# Start the dungeon by placing the player in the large cave
my_dungeon.start(:large_cave)

# Check if there's treasure in this room
my_dungeon.check_treasure


# Player is trapped in dungeon until a key and holy grail are found to unlock main room or player quit
trapped = true
while (trapped)
    puts
    # Ask player for input on what to do (n,s,e,w,p,d,i,q)
    action = my_dungeon.select_action

    print_dashes
    if (action == 'c')
        # find player's location
        my_dungeon.show_current_description

        # Check if there's treasure in this room
        my_dungeon.check_treasure

    elsif (action == 'q')
        # Quit the loop
        trapped = false
        puts "Goodbye."

    elsif (action == 'p')
        # Pick up treasure and put it in satchel
        my_dungeon.pickup_treasure

    elsif (action == 'd')
        # List all treasures in satchel by number
        my_dungeon.show_treasure_in_satchel

        # Ask player to enter the corresponding number to drop off
        item = my_dungeon.select_treasure

        if (item != nil)
            # Drop off treasure in current room
            my_dungeon.dropoff_treasure(item.to_sym)
        end

    elsif (action == 'i')
        # List all treasures in satchel by number
        my_dungeon.show_treasure_in_satchel

    elsif (action == 'w')
        # Go west
        my_dungeon.go(:west)

        # Check if there's treasure in this room
        my_dungeon.check_treasure

    elsif (action == 'e')
        # Go east
        my_dungeon.go(:east)

        # Check if there's treasure in this room
        my_dungeon.check_treasure

    elsif (action == 's')
        # Go south
        my_dungeon.go(:south)

        # Check if there's treasure in this room
        my_dungeon.check_treasure

    elsif (action == 'n')

        # If next room is NOT main room, then enter
        if (!my_dungeon.main?)
            # Go north
            my_dungeon.go(:north)

            # Check if there's treasure in this room
            my_dungeon.check_treasure

        # Next room is main but player has no key
        elsif (!my_dungeon.has_key?)
            puts "Sorry, you need the key to enter main room"

        # Next room is main but player has no holy grail
        elsif (!my_dungeon.has_holy_grail?)
            puts "Sorry, you haven't found the holy grail to enter main room"

        # Next room is main and player has both key and holy grail, so enter main room
        elsif (my_dungeon.has_key? && my_dungeon.has_holy_grail?)
            my_dungeon.go(:north)
            trapped = false
            puts "Congratulations! You found the 'Key' and 'Holy Grail'."
            puts "Good luck on your next adventure."
        end
    end
end # end of while(trap)
