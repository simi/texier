##########################################################################################
#
# This file is part of TexieR - universal text to html converter.
#
# == Author
#
# rane <rane@metatribe.org>
#
# == Copyright
#
# Original version:
#   Copyright (c) 2004-2006 David Grudl
#
# Ruby port:
#   Copyright (c) 2006 rane
#
# Texier is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License version 2 as published by the Free Software
# Foundation.
#
# Texier is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# == Version
#
#  0.1 ($Revision$ $Date$)
#
##########################################################################################

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