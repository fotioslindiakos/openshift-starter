#!/var/www/openshift/broker/script/rails runner

# Usage: ./modify_user_resources.rb <username> <option> <value>

require 'yaml'

def max_storage_per_gear(values)
  _proc = proc{ @user.capabilities['max_storage_per_gear'] }

  change_value(_proc) do
    (storage = *values) or return
    @user.capabilities['max_storage_per_gear'] = storage.to_i
    @user.capabilities_will_change!
    @user.save
  end
end

def max_gears(values)
  _proc = proc{@user.max_gears}

  change_value(_proc) do
    (gears = *values) or return

    @user.max_gears = gears.to_i
    @user.save
  end
end

# Helpers
def change_value(_proc,&block)
  name = caller[0][/`.*'/][1..-2]
  puts "Current %s: %s" % [name,_proc.call]
  yield or return
  puts "New %s: %s" % [name,_proc.call]
end

def get_app(name)
  @user.applications.select{|x| x.name == name }.first or abort("No app found!")
end

@user = CloudUser.find(ARGV.shift) or abort("No user found!")

command = ARGV.shift
args = ARGV

send(command,args)
