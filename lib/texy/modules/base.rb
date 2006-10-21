class Texy
    module Modules
        # Base class for Texy modules
        class Base
            attr_accessor :allowed
            attr_reader :texy

            def initialize(texy)
                @texy = texy
                @texy.register_module(self)

                self.allowed = :all
            end

            # Register all line & block patterns a routines.
            def init
            end

            # block's pre-process
            def pre_process(text)
                text
            end

            # block's post-process
            def post_process(text)
                text
            end

            # single line post-process
            def line_post_process(line)
                line
            end
        end
    end
end