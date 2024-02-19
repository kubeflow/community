# Signing off commits

To automatically sign off on every commit, copy the [prepare-commit-msg](prepare-commit-msg) file to the `.git/hooks` directory in your repo or if you already have such a hook, merge the contents into your existing hook.

You can also sign off your contributions manually by doing ONE of the following:
* Use `git commit -s ...` with each commit to add the sign-off or
* Manually add a `Signed-off-by: Your Name <your.email@example.com>` to each commit message.