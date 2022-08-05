#
# Usage:
#   git_shadow HEAD~1
#   git_shadow --root
#

git_shadow() {
    USER_NAME=`git config user.name`
    USER_EMAIL=`git config user.email`
    USER_DATE=`date`

    GIT_AUTHOR_NAME="$USER_NAME" \
    GIT_AUTHOR_EMAIL="$USER_EMAIL" \
    GIT_AUTHOR_DATE="$USER_DATE" \
    GIT_COMMITTER_NAME="$USER_NAME" \
    GIT_COMMITTER_EMAIL="$USER_EMAIL" \
    GIT_COMMITTER_DATE="$USER_DATE" \
        git rebase --reset-author --sign --no-signoff $*
}

export -f git_shadow
