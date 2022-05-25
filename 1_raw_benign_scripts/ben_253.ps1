if(-not $env:appveyor_pull_request_number) {
    git clone -q --branch=$env:appveyor_repo_branch https://github.com/$env:appveyor_repo_name.git $env:appveyor_build_folder
    git checkout -qf $env:appveyor_repo_commit
} else {
    git clone -q https://github.com/$env:appveyor_repo_name.git $env:appveyor_build_folder
    git fetch -q origin +refs/pull/$env:appveyor_pull_request_number/merge:
    git checkout -qf FETCH_HEAD
}