module Make10
  def self.calc(nums, opt = {})
    case opt[:logic]
    when :all_combinations
      require_relative 'make10_all_combinations'
      Make10AllCombinations.new(nums, opt).calc

    when :recursive, nil
      require_relative 'make10_recursive'
      Make10Recursive.new(nums, opt).calc

    end
  end

  def self.cmdline
    require 'optparse'
    opt = OptionParser.new
    options = {output: STDOUT}
    opt.on('-r', '--result=N'){|v| options[:target] = v.to_i }
    opt.on('-v', '--verbose'){ options[:verbose] = true }
    opt.on('-l', '--logic=LOGICNAME', 'recursive (default) or all_combinations'){|v| options[:logic] = v.to_sym }
    opt.getopts
    self.calc(ARGV.shift, options)
  end
end

if __FILE__ == $0
  Make10.cmdline
end
