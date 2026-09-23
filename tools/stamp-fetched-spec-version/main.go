package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/nentgroup/svn-sdk-ts/tools/internal/stamputil"
)

func main() {
	root, err := stamputil.RepoRoot()
	if err != nil {
		stamputil.Fatal(err)
	}

	service := os.Getenv("SERVICE")
	if service == "" {
		stamputil.Fatal(fmt.Errorf("SERVICE is required"))
	}

	specRef := os.Getenv("SPEC_REF")
	if specRef == "" {
		stamputil.Fatal(fmt.Errorf("SPEC_REF is required"))
	}

	specPath := filepath.Join(root, "api", service+".yml")
	data, err := os.ReadFile(specPath)
	if err != nil {
		stamputil.Fatal(fmt.Errorf("reading %s: %w", specPath, err))
	}

	updated, changed := stampInfoVersion(string(data), specRef)
	if !changed {
		stamputil.Fatal(fmt.Errorf("failed to stamp info.version in %s", specPath))
	}

	if err := os.WriteFile(specPath, []byte(updated), 0o644); err != nil {
		stamputil.Fatal(fmt.Errorf("writing %s: %w", specPath, err))
	}
}

func stampInfoVersion(content, version string) (string, bool) {
	lines := strings.Split(content, "\n")
	inInfo := false
	infoIndent := -1

	for i, line := range lines {
		trimmed := strings.TrimSpace(line)
		if !inInfo {
			if trimmed == "info:" {
				inInfo = true
				infoIndent = stamputil.LeadingIndent(line)
			}
			continue
		}

		if trimmed == "" {
			continue
		}

		indent := stamputil.LeadingIndent(line)
		if indent <= infoIndent {
			break
		}

		if strings.HasPrefix(strings.TrimLeft(line, " \t"), "version:") {
			prefix := line[:len(line)-len(strings.TrimLeft(line, " \t"))]
			comment := ""
			if idx := strings.Index(line, "#"); idx != -1 {
				comment = " " + strings.TrimSpace(line[idx:])
			}
			lines[i] = fmt.Sprintf(`%sversion: "%s"%s`, prefix, version, comment)
			return stamputil.JoinPreservingTrailingNewline(lines, content), true
		}
	}

	return content, false
}
