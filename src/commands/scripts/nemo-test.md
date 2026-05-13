# nemo-test

Run `sbt test` for one or more Nemo projects, each in its own WezTerm tab.

---

## Usage

```sh
nemo-test                                        # interactive menu
nemo-test nemo-mpedia                            # single project
nemo-test nemo-mpedia nemo-cms-proxy             # two specific projects
nemo-test nemo-mpedia nemo-mpedia-importer nemo-cms-proxy  # all three
nemo-test --help                                 # show usage
```

---

## How it works

For each selected project, the script:
1. Opens a new tab in the current WezTerm window
2. Sets the tab title and the window title to the project name
3. Runs `sbt test` inside the project directory
4. Keeps the tab open after the tests finish so you can read the output

All tabs open simultaneously — tests run in parallel, each in full isolation with its own JVM.

---

## Adding a new project

Open the script and add a line to the `AVAILABLE_PROJECTS` array at the top:

```sh
AVAILABLE_PROJECTS=(
  "nemo-mpedia:/Users/pwt9708/SpringerNature/Projects/nemo/apps/nemo-mpedia"
  "nemo-mpedia-importer:/Users/pwt9708/SpringerNature/Projects/nemo/apps/nemo-mpedia-importer"
  "nemo-cms-proxy:/Users/pwt9708/SpringerNature/Projects/nemo/apps/nemo-cms-proxy"
  "your-new-project:/absolute/path/to/your-new-project"   # <-- add here
)
```

The format is `"display-name:/absolute/path"`. The display name is what you type as an argument and what appears as the tab title.

---

## Requirements

- **WezTerm** must be running (the script opens tabs in your current WezTerm window)
- **sbt** must be on your `PATH`
