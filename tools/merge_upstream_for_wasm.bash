#!/bin/bash

set -e

prev_branch="$(git name-rev --name-only HEAD)"

function current_version_from_commits() {
    local hash msg line
    while IFS= read -r line; do
        hash="${line%% *}"
        msg="${line#* }"
        if [[ "$msg" =~ ^patch\ ([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+): ]]; then
            echo "${hash} ${BASH_REMATCH[1]}"
            return
        fi
    done < <(git log --pretty='%H %s' --max-count=100)
    echo '+ Version could not be detected in commit messages' 1>&2
    git checkout "${prev_branch}" >/dev/null
    exit 1
}

git checkout upstream >/dev/null

before="$(current_version_from_commits)"
before_hash="${before%% *}"
before_ver="${before#* }"

echo '+ Pulling upstream...'
git pull https://github.com/vim/vim.git master >/dev/null

after="$(current_version_from_commits)"
after_hash="${after%% *}"
after_ver="${after#* }"

if [[ "$before" == "$after" ]]; then
    echo "+ No new patch was found. The latest version is still '${before_ver}' (${before_hash})" 1>&2
    git checkout "${prev_branch}" >/dev/null
    exit 1
fi

echo
echo '+ Detected new patches:'
echo "    Before version=${before_ver} (${before_hash})"
echo "    After version=${after_ver} (${after_hash})"

echo
echo "+ Merging ${before_ver}...${after_ver}"

git log --oneline --graph "HEAD...${before_hash}"

git checkout wasm >/dev/null

echo '+ Creating new branch...'
git checkout -b "merge-from-${before_ver}-to-${after_ver}"

echo '+ Merging upstream. It would cause confilicts...'
set +e
git merge upstream --no-commit
merge_exit=$?
set -e

echo '+ Updating version constants...'
before_ver_regex="${before_ver//./\\.}"
sed -i '' -E "s/${before_ver_regex}/${after_ver}/" ./README.md ./wasm/vimwasm.ts ./wasm/README.md

if [[ "$merge_exit" == 0 ]]; then
    echo '+ Merge succeeded. Please check status and create a merge commit by `git commit`'
else
    echo '+ Merge failed due to conflict. Please resolve conflict and create a merge commit by `git commit`'
fi
exit $merge_exit
