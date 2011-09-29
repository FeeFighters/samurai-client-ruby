require 'bigdecimal'

module TransactionSeed

  def next_seed
    @@seed ||= BigDecimal.new(rand(1000).to_s) / BigDecimal.new('100.0') + BigDecimal.new('100.0')
    @@seed += BigDecimal.new('1.0')
  end

end
