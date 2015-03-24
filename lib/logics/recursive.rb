require_relative 'base'

class Make10::Recursive < Make10::Base
  def _calc
    calc_recursive(@nums)
  end

  def calc_recursive(nums, fomulas = [])
    if nums.size == 1
      @trials += 1
      if nums.first == @target
        found(fomulas.first)
      else
        # failed trial
        #output("#{fomulas.first} = #{@target}")
      end
      return
    end

    # pos = [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3]] for 4 digits
    # pos = [[0, 1], [0, 2], [1, 2]] for 3 digits
    # pos = [[0, 1]] for 2 digits
    # each pair couse 6 calculations as below (+-*/ and another -/)
    # so calculation should be ran 6*6*3*6*1*6(=3888) - <0 divide> times max
    pos = (0..(nums.size - 1)).to_a.combination(2).to_a

    # remove duplicated calculations with same number combination
    # safe only for 1st level calculation
    if fomulas.size == 0 and 1 < pos.size and @remove_redundant
      pos.uniq!{|a,b| [nums[a], nums[b]]}
    end

    pos.each do |pos_a, pos_b|
      nn = nums.dup
      ff = fomulas.dup
      # bb is the number at pos_b
      bb = nn.delete_at(pos_b)
      bbs = ff[pos_b] ? "(#{ff.delete_at(pos_b)})" : bb.to_i.to_s
      # aa is the number at pos_a
      # when aa is taken, pos_b will be shifted in nn, so this flow is needed
      aa = nn.delete_at(pos_a)
      aas = ff[pos_a] ? "(#{ff.delete_at(pos_a)})" : aa.to_i.to_s

      calc_recursive([aa + bb, *nn], ["#{aas} + #{bbs}", *ff])
      calc_recursive([aa - bb, *nn], ["#{aas} - #{bbs}", *ff])
      calc_recursive([aa * bb, *nn], ["#{aas} * #{bbs}", *ff])
      calc_recursive([aa / bb, *nn], ["#{aas} / #{bbs}", *ff]) unless bb == 0
      calc_recursive([bb - aa, *nn], ["#{bbs} - #{aas}", *ff])
      calc_recursive([bb / aa, *nn], ["#{bbs} / #{aas}", *ff]) unless aa == 0
    end
    nil
  end
end

if __FILE__ == $0
  Make10::Recursive.cmdline
end
