require_relative 'base'

class Make10::Recursive < Make10::Base
  def _calc
    calc_recursive([], *@nums)
  end

  def calc_recursive(fomula, *nums)
    @count += 1
    if nums.size == 1
      if nums.first == @target
        found(fomula.first)
      else
        #output("#{fomula.first} = #{@target}")
      end
      return
    end
    pos = (0..(nums.size - 1)).to_a.combination(2).to_a
    pos.each do |pos_a, pos_b|
      nn = nums.dup
      ff = fomula.dup
      bb = nn.delete_at(pos_b)
      bbs = bb.to_f.to_s.sub(/\.0$/,'')
      bbs = "(#{ff.delete_at(pos_b)})" if ff[pos_b]
      aa = nn.delete_at(pos_a)
      aas = aa.to_f.to_s.sub(/\.0$/,'')
      aas = "(#{ff.delete_at(pos_a)})" if ff[pos_a]
      calc_recursive(["#{aas} + #{bbs}", *ff], aa + bb, *nn)
      calc_recursive(["#{aas} - #{bbs}", *ff], aa - bb, *nn)
      calc_recursive(["#{aas} * #{bbs}", *ff], aa * bb, *nn)
      calc_recursive(["#{aas} / #{bbs}", *ff], aa / bb, *nn) unless bb == 0
      calc_recursive(["#{bbs} - #{aas}", *ff], bb - aa, *nn)
      calc_recursive(["#{bbs} / #{aas}", *ff], bb / aa, *nn) unless aa == 0
    end
    nil
  end
end

if __FILE__ == $0
  require 'optparse'
  result = 10
  opt = OptionParser.new
  opt.on('-r', '--result=N'){|v| result = v }
  Make10::Recursive.new(ARGV.shift, target: result.to_i).calc
end
