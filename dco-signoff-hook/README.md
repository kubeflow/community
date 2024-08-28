# Signing off commits

To automatically sign off on every commit, copy the [prepare-commit-msg](prepare-commit-msg) file to the `.git/hooks` directory in your repo or if you already have such a hook, merge the contents into your existing hook.
You can also configure it globally (for every repo on your machine) by copying the [prepare-commit-msg](prepare-commit-msg) file to the `${HOME}/.git-template/hooks` directory.

You can also sign off your contributions manually by doing ONE of the following:
* Use `git commit -s ...` with each commit to add the sign-off or
* Manually add a `Signed-off-by: Your Name <your.email@example.com>` to each commit message; please note that Name and Email of sign-off must match the commit's Author, in other words the `user.name` and `user.email` of the git configuration used when creating the commit. Using `git commit -s ...` does this automatically.

The email address must match your primary GitHub email. You do NOT need cryptographic (e.g. gpg) signing.
* Use `git commit -s --amend ...` to add a sign-off to the latest commit, if you forgot.

*Note*: Some projects will provide specific configuration to ensure all commits are signed-off. Please check the project's documentation for more details.