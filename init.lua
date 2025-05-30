-- Randomize seed
math.randomseed(os.time())

require("config.base") -- For Vim base configs
require("config.mappings") -- For key mappings
require("config.lazy").setup() -- Package manager
require("config.filetype") -- Filetype extensions
require("config.misc") -- For misc configs
