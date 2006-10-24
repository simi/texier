require 'texy'

module ActionView
    module Helpers
        module TextHelper
            def texy(source, mode = :trusted)
                texy = Texy.new

                texy.trust_mode if mode == :trusted
                texy.safe_mode if mode == :safe

                yield texy if block_given

                texy.process source
            end
        end
    end
end