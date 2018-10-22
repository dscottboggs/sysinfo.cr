module Sysinfo
  # Data read from /proc/stat. See `man 5 proc` on a Linux system.
  class Stat < Info
    getter location = "/proc/stat"

    alias CPU = NamedTuple(
      user: Int32,
      nice: Int32,
      system: Int32,
      idle: Int32,
      iowait: Int32,
      irq: Int32,
      softirq: Int32,
      steal: Int32,
      guest: Int32,
      guest_nice: Int32
    )

    # An array of CPUs from an existing stat instance.
    def cpus
      data = File.read("/proc/stat")
      cpus = [] of CPU
      data.scan(/cpu\d\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/) do |matches|
        cpu = {
          user: matches[1].to_i,
          nice: matches[2].to_i,
          system: matches[3].to_i,
          idle: matches[4].to_i,
          iowait: matches[4].to_i,
          irq: matches[5].to_i,
          softirq: matches[6].to_i,
          steal: matches[7].to_i,
          guest: matches[9].to_i,
          guest_nice: matches[10].to_i,
        }
        cpus << cpu
      end
      cpus
    end

    # An array of CPUs from a new stat instance.
    def self.cpus
      new.cpus
    end

    {% for attr in { :intr, :softirq } %}

    # The text for the "{{ attr.id }}" attribute of an existing stat instance.
    def {{ attr.id }}
        data.scan(/{{ attr.id }}\s(.*)/)[0][1].split.map &.to_i
    end

    # The text for the "{{ attr.id }}" attribute of a new stat instance.
    def self.{{ attr.id }}
        new.{{ attr.id }}
    end

    {% end  %}
    {% for attr in { :ctxt, :btime, :processes, :procs_running, :procs_blocked } %}

    # The text for the "{{ attr.id }}" attribute of an existing stat instance.
    def {{ attr.id }}
        data.scan(/{{ attr.id }}\s(.*)/)[0][1].to_i
    end

    # The text for the "{{ attr.id }}" attribute of a new stat instance.
    def self.{{ attr.id }}
        new.{{ attr.id }}
    end

    {% end  %}
  end
end
