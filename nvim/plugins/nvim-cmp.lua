return {
	"hrsh7th/nvim-cmp",
	opts = {
		experimental = {
			ghost_text = false,
		},
		window = {
			completion = require("cmp").config.window.bordered(),
			documentation = require("cmp").config.window.bordered(),
		},
	},
}
