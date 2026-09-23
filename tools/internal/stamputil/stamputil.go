package stamputil

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

type BlockUpdate struct {
	Start   string
	End     string
	Content string
}

func Fatal(err error) {
	_, _ = fmt.Fprintln(os.Stderr, err)
	os.Exit(1)
}

func RepoRoot() (string, error) {
	exePath, err := os.Executable()
	if err == nil {
		root := filepath.Clean(filepath.Join(filepath.Dir(exePath), "..", ".."))
		if isRepoRoot(root) {
			return root, nil
		}
	}

	wd, err := os.Getwd()
	if err != nil {
		return "", fmt.Errorf("getting working directory: %w", err)
	}

	root := wd
	for {
		if isRepoRoot(root) {
			return root, nil
		}
		parent := filepath.Dir(root)
		if parent == root {
			break
		}
		root = parent
	}

	return "", fmt.Errorf("could not locate repository root from %s", wd)
}

func isRepoRoot(root string) bool {
	if _, statErr := os.Stat(filepath.Join(root, "package.json")); statErr == nil {
		return true
	}
	if _, statErr := os.Stat(filepath.Join(root, ".git")); statErr == nil {
		return true
	}
	return false
}

func ResolveSDKVersion(root string) string {
	if version := strings.TrimSpace(os.Getenv("SDK_VERSION")); version != "" {
		return version
	}

	packageJSONPath := filepath.Join(root, "package.json")
	if data, err := os.ReadFile(packageJSONPath); err == nil {
		var manifest struct {
			Version string `json:"version"`
		}
		if err := json.Unmarshal(data, &manifest); err == nil {
			if version := strings.TrimSpace(manifest.Version); version != "" {
				if strings.HasPrefix(version, "v") {
					return version
				}
				return "v" + version
			}
		}
	}

	commands := [][]string{
		{"git", "describe", "--tags", "--abbrev=0", "--match", "v[0-9]*"},
		{"git", "tag", "--list", "v[0-9]*", "--sort=-version:refname"},
	}

	for _, command := range commands {
		cmd := exec.Command(command[0], command[1:]...)
		cmd.Dir = root
		output, err := cmd.Output()
		if err != nil {
			continue
		}

		for _, line := range strings.Split(strings.TrimSpace(string(output)), "\n") {
			if version := strings.TrimSpace(line); version != "" {
				return version
			}
		}
	}

	return "v0.0.0"
}

func ReplaceBlock(text string, update BlockUpdate, path string) (string, error) {
	startIndex := strings.Index(text, update.Start)
	if startIndex == -1 {
		return "", fmt.Errorf("failed to find block start %q in %s", update.Start, path)
	}

	searchFrom := startIndex + len(update.Start)
	endOffset := strings.Index(text[searchFrom:], update.End)
	if endOffset == -1 {
		return "", fmt.Errorf("failed to find block end %q in %s", update.End, path)
	}
	endIndex := searchFrom + endOffset

	var buf bytes.Buffer
	buf.WriteString(text[:startIndex])
	buf.WriteString(update.Start)
	buf.WriteString("\n")
	buf.WriteString(update.Content)
	buf.WriteString("\n")
	buf.WriteString(update.End)
	buf.WriteString(text[endIndex+len(update.End):])

	return buf.String(), nil
}

func LeadingIndent(line string) int {
	return len(line) - len(strings.TrimLeft(line, " \t"))
}

func JoinPreservingTrailingNewline(lines []string, original string) string {
	joined := strings.Join(lines, "\n")
	if strings.HasSuffix(original, "\n") && !strings.HasSuffix(joined, "\n") {
		var buf bytes.Buffer
		buf.WriteString(joined)
		buf.WriteByte('\n')
		return buf.String()
	}
	return joined
}
