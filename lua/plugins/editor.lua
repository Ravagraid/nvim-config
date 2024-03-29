return {
	--File Explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		lazy = false,
		branch = "v3.x",
		dependencies = {
			{ "nvim-lua/plenary.nvim", lazy = true },
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			popup_border_style = "rounded",
			filesystem = {
				filtered_items = {
					hide_dotfiles = true,
					hide_gitignored = true,
					hide_hidden = false,
				},
				hijack_netrw_behavior = "open_current",
			},
			git_status = {
				symbols = {
					-- Status type
					untracked = "",
					ignored = "",
					unstaged = "󰄱",
					staged = "",
					conflict = "",
				},
			},
			event_handlers = {
				{
					event = "file_opened",
					---@diagnostic disable-next-line: unused-local
					handler = function(file_path)
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
			},
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = function()
			local actions = require("telescope.actions")
			return {
				defaults = {
					file_ignore_patterns = { "node_modules", "yarn.lock" },
					dynamic_preview_title = true,
					path_display = { "smart" },
					mappings = {
						i = {
							["<esc>"] = actions.close,
						},
					},
				},
				layout_config = {
					horizontal = {
						preview_cutoff = 100,
						preview_width = 0.6,
					},
				},
			}
		end,
	},
	{
		"folke/trouble.nvim",
		cmd = { "TroubleToggle", "Trouble" },
		opts = { use_diagnostic_signs = true },
		keys = {
			{ "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
			{ "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
			{ "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").previous({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cprev)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				"Previous trouble/quickfix item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cnext)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				"Next trouble/quickfix item",
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		lazy = false,
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			current_line_blame = true,
		},
		init = function()
			require("gitsigns").setup()
		end,
	},
	{
		"RRethy/vim-illuminate",
		event = "VeryLazy",
		opts = {
			delay = 200,
			large_file_cutoff = 2000,
			large_file_overrides = {
				providers = { "lsp" },
			},
		},
		config = function(_, opts)
			require("illuminate").configure(opts)

			local function map(key, dir, buffer)
				vim.keymap.set("n", key, function()
					require("illuminate")["goto_" .. dir .. "_reference"](false)
				end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
			end

			map("]]", "next")
			map("[[", "prev")

			-- also set it after loading ftplugins, since a lot overwrite [[ and ]]
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					local buffer = vim.api.nvim_get_current_buf()
					map("]]", "next", buffer)
					map("[[", "prev", buffer)
				end,
			})
		end,
		keys = {
			{ "]]", desc = "Next Reference" },
			{ "[[", desc = "Prev Reference" },
		},
	},
	{ "folke/twilight.nvim" },
	{ "mg979/vim-visual-multi" },
	{
		"nvim-neorg/neorg",
		build = ":Neorg sync-parsers",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("neorg").setup({
				load = {
					["core.integrations.nvim-cmp"] = {},
					["core.integrations.treesitter"] = {},
					["core.defaults"] = {}, -- Loads default behaviour
					["core.autocommands"] = {},
					["core.concealer"] = {}, -- Adds pretty icons to your documents
					["core.completion"] = {
						config = {
							engine = "nvim-cmp",
						},
					},
					["core.dirman"] = { -- Manages Neorg workspaces
						config = {
							workspaces = {
								general = "~/Documents/General Vault/",
							},
						},
					},
					["core.summary"] = {},
				},
			})
		end,
	},
}
