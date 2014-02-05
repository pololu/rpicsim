# This plug allows us to customize the way our documentation looks
# by overriding some ERB templates provided by YARD.
# We add a link to the Manual at the top and bottom of every page in the manual.
YARD::Templates::Engine.register_template_path File.dirname(__FILE__) + "/templates"
