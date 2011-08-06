class Samurai::ProcessorResponse < Samurai::Base

  def avs_result_code
    avs_result_code_message = self.messages.find {|m| m.context=='processor.avs_result_code' || m.context=='gateway.avs_result_code' }
    avs_result_code_message && avs_result_code_message.key
  end

end