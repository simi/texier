class Texy
    class Html

        # HTML support for Texy!
        class WellForm

            # Fix misplaced tags.
            #
            # For example, turn
            #     <strong><em> ... </strong> ... </em>
            # into
            #     <strong><em> ... </em></strong><em> ... </em>
            def process(text)
                text
            end
        end
    end
end