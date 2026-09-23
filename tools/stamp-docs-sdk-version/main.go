package main

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/nentgroup/svn-sdk-ts/tools/internal/stamputil"
)

func main() {
	root, err := stamputil.RepoRoot()
	if err != nil {
		stamputil.Fatal(err)
	}

	version := stamputil.ResolveSDKVersion(root)

	files := map[string][]stamputil.BlockUpdate{
		filepath.Join(root, "docs", "README.md"): {
			{
				Start:   "<!-- BEGIN GENERATED SDK VERSION -->",
				End:     "<!-- END GENERATED SDK VERSION -->",
				Content: fmt.Sprintf("> SDK version: `%s`", version),
			},
		},
		filepath.Join(root, "docs", "_coverpage.md"): {
			{
				Start:   "<!-- BEGIN GENERATED SDK VERSION -->",
				End:     "<!-- END GENERATED SDK VERSION -->",
				Content: fmt.Sprintf("> %s", version),
			},
		},
		filepath.Join(root, "docs", "index.html"): {
			{
				Start:   "<!-- BEGIN GENERATED SDK HTML TITLE -->",
				End:     "<!-- END GENERATED SDK HTML TITLE -->",
				Content: fmt.Sprintf("  <title>SVN SDK for TypeScript %s</title>", version),
			},
		},
		filepath.Join(root, "docs", "api-reference.html"): {
			{
				Start:   "<!-- BEGIN GENERATED SDK HTML TITLE -->",
				End:     "<!-- END GENERATED SDK HTML TITLE -->",
				Content: fmt.Sprintf("    <title>Viasport API Reference — SVN SDK for TypeScript %s</title>", version),
			},
			{
				Start:   "        <!-- BEGIN GENERATED SDK API REF TITLE -->",
				End:     "        <!-- END GENERATED SDK API REF TITLE -->",
				Content: fmt.Sprintf("        <span class=\"topbar__title\">Viasport API Reference %s</span>", version),
			},
		},
	}

	for path, updates := range files {
		data, err := os.ReadFile(path)
		if err != nil {
			stamputil.Fatal(fmt.Errorf("reading %s: %w", path, err))
		}

		text := string(data)
		for _, update := range updates {
			text, err = stamputil.ReplaceBlock(text, update, path)
			if err != nil {
				stamputil.Fatal(err)
			}
		}

		if err := os.WriteFile(path, []byte(text), 0o644); err != nil {
			stamputil.Fatal(fmt.Errorf("writing %s: %w", path, err))
		}
	}
}
